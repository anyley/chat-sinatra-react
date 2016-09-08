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
                             type:   :hello
        end
        
        def error(socket, message)
          @protocol.dispatch socket,
                             source: :server,
                             type:   :error,
                             params: { message: message }
        end
        
        def welcome(socket)
          userlist = @protocol.ws.store[:clients].each_value.map { |client| client[:username] }.select {|i| !i.nil?}
          @protocol.dispatch socket,
                             source: :server,
                             type:   :welcome,
                             params: { userlist: userlist,
                                       username: @protocol.ws.username_by_wsh(socket) }
        end
        
        def add_user(socket, username)
          @protocol.dispatch socket,
                             source: :server,
                             type:   :add_user,
                             params: { username: username,
                                       uuid:     SecureRandom.uuid }
        end

        def del_user(socket, username)
          @protocol.dispatch socket,
                             source: :server,
                             type:   :del_user,
                             params: { username: username,
                                       uuid:     SecureRandom.uuid }
        end

        def broadcast(socket, message)
          @protocol.dispatch socket,
                             source: :server,
                               type: :broadcast,
                             params: { timestamp: timestamp,
                                          sender: @protocol.ws.username_by_wsh(socket),
                                         message: message,
                                            uuid: SecureRandom.uuid }
        end
        
        def private(socket, recipient, message)
          @protocol.dispatch socket, 
                             source: :server,
                             type:   :private,
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
