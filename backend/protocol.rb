# coding: utf-8
module Chat
  module Protocol
    class UnknownEvent   < Exception; end
    class Unknown        < Exception; end
    class BadSource      < Exception; end
    class BadAction      < Exception; end
    class BadParameters  < Exception; end

    class Simple
      attr_accessor :server, :client, :ws
      
      class ClientActions
        def initialize(protocol)
          @protocol = protocol
        end
      end
      
      class ServerActions
        def initialize(protocol)
          @protocol = protocol
        end

        # hello:     [:client],
        # welcome:   [:client],
        # error:     [:client, :message],
        # add_user:  [:username],
        # del_user:  [:username],
        # broadcast: [:timestamp, :username, :message],
        # private:   [:timestamp, :sender, :recipient, :message]
        def hello(socket)
          @protocol.dispatch socket, source: :server, action: :hello
        end
        
        def error(socket, message)
          @protocol.dispatch socket, source: :server, action: :error, params: {message: message}
        end
        
        def welcome(socket)
          @protocol.dispatch socket, source: :server, action: :welcome
        end
        
        def add_user(socket, username)
          @protocol.dispatch socket, source: :server, action: :add_user, params: {username: username}
        end

        def del_user(socket, username)
          @protocol.dispatch socket, source: :server, action: :del_user, params: {username: username}
        end
        
      end

      def server
        @server
      end

      def client
        @client
      end

      def initialize(ws)
        @ws = ws
        @server = ServerActions.new self
        @client = ClientActions.new self
      end

      # MESSAGE_FORMAT =
      #   :src  = :server | :client
      #   :action  = CLIENT_COMMANDS_FORMAT | SERVER_COMMANDS_FORMAT
      #   :data = соответственно по заданным ниже форматам
      MESSAGE_FORMAT  = [:source, :action]

      # Схема взаимодействия по протоколу
      #
      #    [open]
      #    :hello ->
      #
      #    [message]
      # <- :login
      #    :welcome|:error ->
      #     if :welcome then :add_user ==>
      # <- :update
      #    :user_list ->
      # <- :broadcast
      #    :broadcast ==>
      # <- :private
      #    :private ->
      # <- :logout
      #    :del_user ==>
      #
      #     [close]
      #     if user exists then :del_user ==>
      #
      ACTIONS_FORMATS = {
        # source
        client: {
          # commands  params
          login:     [:username],
          logout:    [],
          update:    [],
          broadcast: [:message],
          private:   [:username, :message]
        },
        server: {
          hello:     [],
          welcome:   [],
          error:     [:message],
          add_user:  [:username],
          del_user:  [:username],
          broadcast: [:timestamp, :username, :message],
          private:   [:timestamp, :sender, :recipient, :message]
        }
      }


      def validate!(message)
        # сообщение н едолжно быть nil
        raise Unknown if message.nil?

        # сообщение должно содержать обязательные параметры
        unless MESSAGE_FORMAT == MESSAGE_FORMAT & message.keys
          raise Unknown
        end

        message_source = message[:source].to_sym

        # сообщение должно быть от валидного источника
        unless ACTIONS_FORMATS.has_key? message_source
          raise BadSource
        end

        message_action = message[:action].to_sym
        message_params  = message[:params] || {}

        # находим список валидных команд для источника сообщения
        format_actions = ACTIONS_FORMATS[message_source]
        # сообщение должно содержать релевантную команду от источника
        unless format_actions.has_key? message_action
          raise BadAction
        end

        # находим формат параметров
        format_params = format_actions[message_action]

        # проверка на наличие обязательных параметров для команды сообщения
        unless format_params == format_params & message_params.keys
          raise BadParameters
        end

        # все Оk
        {source: message_source, action: message_action, params: message_params}
      end

      
      # Первичный обработчик сообщений поступающих через websocket
      def handle(client, event, data = '{}')
        data = JSON.parse(data, symbolize_names: true)

        case event
        when :open
          # TODO: server.save_socket
#          @ws.save_client client, { username: nil }
          server.hello client

        when :message
          dispatch client, data

        when :close
          server.del_user client, @ws.username_by_socket(client)

          # TODO: server.delete_socket
          @ws.del_client client

        else
          raise UnknownEvent
        end
      end


      # принимает строку в json-формате
      def dispatch(client, data)
        message = validate! data

        # message = JSON.parse message, symbolize_names: true
        case message[:source]
        when :client
        # let(:login_cmd)     { { source: "client", action: "login",
        #                         params: { username: "John Doe" } } }
        # let(:logout_cmd)    { { source: "client", action: "logout",
        #                         params: {} } }
        # let(:update_cmd)    { { source: "client", action: "update",
        #                         params: {} } }
        # let(:broadcast_cmd) { { source: "client", action: "broadcast",
        #                         params: { message: "hi all" } } }
        # let(:private_cmd)   { { source: "client", action: "private",
        #                         params: { username: "John Doe",
        #                                   message:  "Hi John!" } } }            case message[:action]
          case message[:action]
          when :login
            username = data[:params][:username]
            if @ws.store[:clients].has_value? username
              server.error client, 'Username already used'
            else
              @ws.save_client client, username
              server.welcome client
              server.add_user client, username
            end
          when :logout
            puts message[:action]
          when :update
            puts message[:action]
          when :broadcast
            puts message[:action]
          when :private
            puts message[:action]
          end
        

        # let(:hello_cmd)     { { source: "server", action: "hello",
        #                         params: { client: nil } } }
        # let(:welcome_cmd)   { { source: "server", action: "welcome",
        #                         params: { client: nil } } }
        # let(:error_cmd)     { { source: "server", action: "error",
        #                         params: { client:  nil,
        #                                   message: 'Имя занято' } } }
        # let(:add_user_cmd)  { { source: "server", action: "add_user",
        #                         params: { username: "John Doe" } } }
        # let(:del_user_cmd)  { { source: "server", action: "del_user",
        #                         params: { username: "John Doe" } } }
        # let(:broadcast_cmd) { { source: "server", action: "broadcast",
        #                         params: { timestamp: 1471935709105,
        #                                   username:  "John Doe",
        #                                   message:   'My name John Doe' } } }
        # let(:private_cmd)   { { source: "server", action: "private",
        #                         params: { timestamp: 1471935709105,
        #                                   sender:    "John Doe",
        #                                   recipient: "user_2",
        #                                   message:   'My name John Doe' } } }          when :server
        when :server
          case message[:action]
          when :hello
#            puts message[:action]
            @ws.send client, data
            
          when :welcome
#            puts message[:action]
            @ws.send client, data
          when :error
#            puts message[:action]
            @ws.send client, data
          when :add_user
          #            puts message[:action]
            @ws.broadcast data
          when :del_user
 #           puts message[:action]
          when :broadcast
            puts message[:action]
          when :private
            puts message[:action]
          end
        end
      end
    end
  end
end
