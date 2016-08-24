require 'sinatra/base'
require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'

# Плагины для обработки клиентских сообщений
require './backend/plugins/json_traverse'
require './backend/plugins/sanitize'
require './backend/plugins/href_maker'

require './backend/local_queue'
require './backend/redis_queue'
require './backend/protocol'


module Chat
  KEEPALIVE_TIME = 15
  DEFAULT_CHAT   = "main"

  # Предки класса Server должны иметь метод publish
  # для помещения сообщений в очередь для рассылки через broadcast
  # В данном коде два валидных предка RedisQueue и LocalQueue
  class Server
    # include Chat::Protocol

    def initialize(redirector)
      # super(redirector)
      @redirector = redirector
      @clients    = {}
      @queue      = RedisQueue.new(self)
      @store      = {clients: {}, users: []}
    end

    def broadcast(msg)
      @clients.each do |client, info|
        client.send(JSON.generate(msg)) if info[:channels].include? msg['channel']
      end
    end

    def call(env)
      puts 'Server call'
      # проверка поступления WebSocket-запроса
      if Faye::WebSocket.websocket?(env)
        # стандартный life-цикл Faye::WebSocket :open, :message, :close
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          puts 'new connection open'
          Protocol.handleEvent :open, websocket: ws, store: @store
        end

        ws.on :message do |event|
          puts 'message received from client'
          Protocol.handleEvent :message, websocket: ws, store: @store, data: event.data
        end

        ws.on :close do |event|
          puts 'connection closed'
          Protocol.handleEvent :close, websocket: ws, store: @store
          # ws = nil
        end

        # FIX: По идее должен возвращать статус 101 - Switching Protocols
        # по факту возвращает [-1, {}, []]
        ws.rack_response
      else
        # Обрабатываем http запросы
        @redirector.call(env)
      end
    end

    private
    def process_data(message)
      # json plugin:
      # преобразовывает строку json в ruby hash
      # и обходит полное hash дерево выдавая key, value другим плагинам
      Plugins.json(message) do |val1, key1|
        # sanitize plugin:
        # чистит value от HTML тэгов
        Plugins.sanitize(val1, key1) do |val2, key2|
          # href plugin:
          # по заданному ключу, заменяет URL-ы в value
          # на HTML якоря <a href="$url"> $url </a>
          Plugins.href_maker(val2, key2, 'text')
        end
        # на выходе из json-плагина hash преобразовывается обратно в строку
      end
    end
  end
end
