require 'sinatra/base'
require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'

# Плагины для обработки клиентских сообщений
require './backend/plugins/json_traverse'
require './backend/plugins/sanitize'
require './backend/plugins/href_maker'


module Chat
  KEEPALIVE_TIME = 15
  MAIN_CHANNEL   = "main-chat"

  # Базовый класс для Server
  # Реализована публикация данных в очередь
  # и обработки событий redis для извлечения данных из очереди
  class RedisQueue
    def initialize(redirector=nil)
      @clients      = []
      uri           = URI.parse(ENV["REDIS_URL"])
      @redis_writer = Redis.new(host: uri.host, port: uri.port, password: uri.password)

      # Параллельный поток для приема событий редиса
      Thread.new do
        @redis_listener = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        @redis_listener.subscribe(MAIN_CHANNEL) do |on|
          # вытаскиваем из очереди redis сообщения и рассылаем клиентам
          on.message do |channel, msg|
            puts "Channel: #{channel}, #{msg}"
            broadcast(msg)
            # @clients.each { |ws| ws.send(msg) }
          end
        end
      end
    end

    def publish(data, channel=nil)
      puts 'Redis publish method'
      @redis_writer.publish(channel, data)
    end
  end


  # Базовый класс для Server
  # Локальная реализация рассылки сообщений
  # без очередей, без redis, rabbitmq и прочих
  class LocalQueue
    def initialize(redirector)
    end

    # Как только сообщение поступает от клиента
    # оно сразу же бродкастится всем остальным
    # подключенным к этому же серверу
    def publish(data, channel=nil)
      puts 'Default publish method'
      p JSON.parse(data)
      broadcast(data)
    end
  end


  class Server < LocalQueue

    def initialize(redirector)
      super(redirector)
      @redirector = redirector
      @clients    = []
    end

    def broadcast(msg)
      @clients.each { |ws| ws.send(msg) }
    end

    def call(env)
      # проверка поступления WebSocket-запроса
      if Faye::WebSocket.websocket?(env)
        # стандартный life-цикл Faye::WebSocket :open, :message, :close
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          puts 'new connection open'
          # добавляем нового клиента в список
          @clients << ws
        end

        ws.on :message do |event|
          puts 'message received from client'
          # фильтруем сообщение клиента каскадом плагинов
          data = event.data # process_data(event.data)
          # кладем сообщение в очередь редис для рассылки остальным клиентам
          publish(data, MAIN_CHANNEL)
        end

        ws.on :close do |event|
          puts 'connection closed'
          # при разрыве соединения удаляем клиента из списка
          @clients.delete(ws)
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

  module Protocol
    class Unknown < Exception; end
    class BadMessageType < Exception; end
    class BadCommand < Exception; end

    def dispatch(message)
      raise Protocol::Unknown if message.nil? || message.empty?
      raise Protocol::Unknown unless message.has_key?('cmd') && message.has_key?('data')

      message = JSON.parse(message)

      case message['cmd']
        when 'username'
        when 'get_user_list'
        when 'get_log'
        when 'send'
        when 'delete'
        when 'change'
          
        else
          raise Protocol::BadMessageType
      end

    end
    end

  end
end
