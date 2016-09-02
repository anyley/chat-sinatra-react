require './backend/before_action'
require 'securerandom'

module Chat
  module Protocol
    class Simple
      class ServerActions
        extend Utils::Callbacks

        before_action :check!, :error, :welcome, :add_user, :del_user, :broadcast, :provate

        def initialize(protocol)
          @protocol = protocol
        end

        def timestamp
          Time.now.to_i * 1000
        end

        def hello(socket)
          @protocol.dispatch socket,
                             source: :server,
                             action: :hello
        end
        
        def error(socket, message)
          @protocol.dispatch socket,
                             source: :server,
                             action: :error,
                             params: { message: message }
        end
        
        def welcome(socket)
          p @protocol.ws.store[:clients]
          userlist = @protocol.ws.store[:clients].each_value.map { |client| client[:username] }
          @protocol.dispatch socket,
                             source: :server,
                             action: :welcome,
                             params: { userlist: userlist }
        end
        
        def add_user(socket, username)
          @protocol.dispatch socket,
                             source: :server,
                             action: :add_user,
                             params: { username: username,
                                       uuid:     SecureRandom.uuid }
        end

        def del_user(socket, username)
          @protocol.dispatch socket,
                             source: :server,
                             action: :del_user,
                             params: { username: username,
                                       uuid:     SecureRandom.uuid }
        end

        def broadcast(socket, message)
          @protocol.dispatch socket,
                             source: :server,
                             action: :broadcast,
                             params: { timestamp: timestamp,
                                       sender:    @protocol.ws.username_by_wsh(socket),
                                       message:   message,
                                       uuid:      SecureRandom.uuid }
        end
        
        def private(socket, recipient, message)
          @protocol.dispatch socket, 
                             source: :server,
                             action: :private,
                             params: { timestamp: timestamp,
                                       sender:    @protocol.ws.username_by_wsh(socket),
                                       recipient: recipient,
                                       message:   message,
                                       uuid:      SecureRandom.uuid }
        end

        private
        def check!(client, *args)
          raise BadSocket unless @protocol.ws.store[:clients].has_key? client
        end
      end
    end
  end
end
