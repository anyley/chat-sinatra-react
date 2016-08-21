require 'sinatra/base'
require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'

require './backend/plugins/json_traverse'
require './backend/plugins/sanitize'
require './backend/plugins/href_maker'

module ChatServer

  class WebServer < Sinatra::Base
    # Устанавливаем паблик для вэба /RACK_ROOT/../public
    settings.public_folder = File.join(settings.root, '..', 'public')

    get '/' do
      if (ENV["RACK_ENV"] == 'development')
        # редиректим на webpack-dev-server с hot modules replacement
        redirect 'http://localhost:8080/'
      else
        # если production, то отдаем index.html из паблика
        send_file File.join(settings.public_folder, 'index.html')
      end
    end

  end

  class Chat
    KEEPALIVE_TIME = 15
    MAIN_CHANNEL   = "main-chat"

    def initialize(web_server)
      @web_server   = web_server
      @clients      = []
      uri           = URI.parse(ENV["REDIS_URL"])
      @redis_writer = Redis.new(host: uri.host, port: uri.port, password: uri.password)

      Thread.new do
        @redis_listener = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        @redis_listener.subscribe(MAIN_CHANNEL) do |on|
          # вытаскиваем из очереди redis сообщения
          on.message do |channel, msg|
            puts "Channel: #{channel}, #{msg}"
            @clients.each { |ws| ws.send(msg) }
          end
        end
      end
    end

    def call(env)
      # стандартный life-цикл Faye::WebSocket :open, :message, :close
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          puts 'new connection open'
          @clients << ws
        end

        ws.on :message do |event|
          puts 'message received from client'

          # прогоняем блок параметров от клиента через плагины
          data = Plugins.json(event.data) do |val, key|
                   Plugins.sanitize(val, key) do |val, key|
                     Plugins.href_maker(val, key, 'text')
                   end
                 end

          # чистим текст сообщения и толкаем в очередь redis
          @redis_writer.publish(MAIN_CHANNEL, data)
        end

        ws.on :close do |event|
          puts 'connection closed'
          @clients.delete(ws)
          ws = nil
        end

        ws.rack_response

      else
        # Обрабатываем http запросы
        @web_server.call(env)
      end
    end

    private
    def sanitize(message)
      json = JSON.parse(message)
      json.each do |key, value|
        json[key] = ERB::Util.html_escape(value)
      end
      if json.has_key? 'text'
        json['text'] = json['text'].gsub /(https?:\/\/[\S]+)/, '<a href="\1">\1</a>'
      end
      JSON.generate(json)
    end

  end
end
