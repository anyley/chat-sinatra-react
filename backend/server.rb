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

    # +----------------------------------------+
    # |                                        | 
    # | WebSocket Server API methods           |
    # |                                        |
    # +----------------------------------------+

    def username_by_socket(ws)
      @store[:clients][ws]
    end

    def save_client(client, username)
      @store[:clients][client] = username
    end

    def del_client(client)
      @store[:clients].delete client
    end

    def broadcast(from, data, self_echo=false)
      @store[:clients].each_key do |client|
        client.send(JSON.generate(data)) if self_echo || from != client
      end
    end

    def send(client, data)
      client.send JSON.generate(data)
    end

    def close(client)
      client.close
    end

    # +----------------------------------------+
    # | Основной rack-метод                    | 
    # +----------------------------------------+
    def call(env)
      # проверка поступления WebSocket-запроса
      if Faye::WebSocket.websocket?(env)
        # стандартный life-цикл Faye::WebSocket :open, :message, :close
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })

        ws.on :open do
          puts 'new connection open'
          @protocol.handle ws, :open
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

        ws.on :close do
          puts 'connection closed'
          @protocol.handle ws, :close
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
  end
end
