# coding: utf-8
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

  class Server
    attr_accessor :store, :protocol, :queue

    def initialize(redirector)
      @redirector = redirector
      @queue      = RedisQueue.new(self)
      @store      = { clients: {}, users: {} }
      @protocol   = Chat::Protocol::Simple.new(self)
    end

    def username_by_socket(ws)
      @store[:clients][ws]
    end

    def save_client(client, username)
      @store[:clients][client] = username
    end

    def del_client(client)
      @store[:clients].delete client
    end

    def each_client_send(&block)
      @clients.each do |client, info|
        client.send(JSON.generate(msg)) if yield(info)
      end
    end

    def broadcast(from, data, self_echo=false)
      @store[:clients].each_key do |client|
        client.send(JSON.generate(data)) if self_echo || from != client
      end
    end

    def each_client(&block)
      @store[:clients].each_with_object do |client, clients|
        yield(client, clients)
      end
    end

    def send(client, data)
      client.send JSON.generate(data)
    end

    def close(client)
      client.close
    end

    def call(env)
      # проверка поступления WebSocket-запроса
      if Faye::WebSocket.websocket?(env)
        # стандартный life-цикл Faye::WebSocket :open, :message, :close
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          puts 'new connection open'
          begin
            @protocol.handle ws, :open
          rescue Exception => e
            p e.message
            send ws, error: e.message
          end
        end

        ws.on :message do |event|
          puts 'message received from client'
          begin
            @protocol.handle ws, :message, event.data
          rescue Exception => e
            p e.message
            send ws, error: e.message
          end
        end

        ws.on :close do |event|
          puts 'connection closed'
          begin
            @protocol.handle ws, :close
          rescue Exception => e
            p e.message
            send ws, error: e.message
          end
            
          ws = nil
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
