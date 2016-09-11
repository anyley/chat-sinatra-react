# coding: utf-8
require 'sinatra/base'
require 'faye/websocket'
require 'thread'
require 'json'
# require 'redis'

# require './backend/local_queue'
# require './backend/redis_queue'
require './backend/protocol'


module Chat
  KEEPALIVE_TIME = 15
  DEFAULT_CHAT   = "main"

  class Server
    attr_accessor :store, :protocol, :queue

    def initialize(redirector)
      @redirector = redirector
      # @queue      = RedisQueue.new(self)
      @store      = { clients: {} }
      @protocol   = Chat::Protocol::Simple.new(self)
    end

    # +----------------------------------------+
    # |                                        | 
    # | WebSocket Server API methods           |
    # |                                        |
    # +----------------------------------------+

    def has_username? username
      !@store[:clients].detect { |k, v| v[:username] == username }.nil?
    end

    def wsh_by_username username
      @store[:clients].detect { |k, v| v[:username] == username }[0]
    end

    def socket_by_wsh(wsh)
      @store[:clients][wsh][:ws]
    end

    def username_by_wsh(wsh)
      @store[:clients][wsh][:username]
    end

    def add_client(wsh, username)
      @store[:clients][wsh][:username] = username
    end

    def del_client(wsh)
      @store[:clients].delete wsh
    end

    def broadcast(from, data, self_echo=false)
      @store[:clients].each do |wsh, client|
        send(wsh, data) if (self_echo || from != client[:username]) && client[:username]
      end
    end

    def send(wsh, data)
      socket_by_wsh(wsh).send JSON.generate(data)
    end

    def close(wsh)
      socket_by_wsh(wsh).close
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
          begin
            @store[:clients][ws.hash] = { ws: ws, username: nil }
            @protocol.handle ws.hash, :open
          rescue Exception => e
            puts e
            puts e.backtrace
          end
        end

        ws.on :message do |event|
          puts 'message received from client'
          begin
            @protocol.handle ws.hash, :message, event.data
          rescue Exception => e
            puts e
            puts e.backtrace
            send ws.hash, source: 'server', type: 'error', message: e.message
          end
        end

        ws.on :close do
          puts 'connection closed'
          begin
            @protocol.handle ws.hash, :close
            ws = nil
            p 'closed'
          rescue Exception => e
            puts e
            puts e.backtrace
          end
        end

        # FIX: По идее должен возвращать статус 101 - Switching Protocols
        # по факту возвращает [-1, {}, []]
        ws.rack_response
      else
        # Обрабатываем http запросы
        @redirector.call(env)
      end
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end
end
