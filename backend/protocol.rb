# coding: utf-8
require './backend/before_action'

module Chat
  module Protocol
    class UnknownEvent   < Exception; end
    class Unknown        < Exception; end
    class BadSource      < Exception; end
    class BadAction      < Exception; end
    class BadParameters  < Exception; end
    class UserNotFound   < Exception; end
    class BadSocket      < Exception; end

    class Simple
      attr_accessor :server, :client, :ws
      
      class ServerActions
        extend Utils::Callbacks
        
        def initialize(protocol)
          @protocol = protocol
        end
        
        before_action :check!, :error, :welcome, :add_user, :del_user, :broadcast, :provate

        def check!(client, *args)
          raise BadSocket unless @protocol.ws.store[:clients].has_key? client
        end
                                                      

        def hello(socket)
          @protocol.dispatch socket, source: :server, action: :hello
        end
        
        def error(socket, message)
          @protocol.dispatch socket, source: :server, action: :error, params: {message: message}
        end
        
        def welcome(socket)
          userlist = @protocol.ws.store[:clients].values
          @protocol.dispatch socket, source: :server, action: :welcome, params: { userlist: userlist }
        end
        
        def add_user(socket, username)
          @protocol.dispatch socket, source: :server, action: :add_user, params: {username: username}
        end

        def del_user(socket, username)
          @protocol.dispatch socket, source: :server, action: :del_user, params: {username: username}
        end

        # broadcast: [:timestamp, :username, :message],
        def broadcast(socket, message)
          @protocol.dispatch socket, source: :server,
                                     action: :broadcast,
                                     params: { timestamp: Time.now.to_i,
                                               username:  @protocol.ws.username_by_socket(socket),
                                               message:   message }
        end
        
        # private:   [:timestamp, :sender, :recipient, :message]
        def private(socket, recipient, message)
          @protocol.dispatch socket, source: :server,
                                     action: :private,
                                     params: { timestamp: Time.now.to_i,
                                               sender:    @protocol.ws.username_by_socket(socket),
                                               recipient: recipient,
                                               message:   message }
        end
      end

      def initialize(ws)
        @ws = ws
        @server = ServerActions.new self
      end

      def server
        @server
      end

      def client
        @client
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
          private:   [:recipient, :message]
        },
        server: {
          hello:     [],
          welcome:   [:userlist],
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
          server.hello client

        when :message
          dispatch client, data

        when :close
#          raise UserNotFound unless @ws.store[:clients].has_key? client
          server.del_user client, @ws.username_by_socket(client)
          @ws.del_client client

        else
          raise UnknownEvent
        end
      end


      # принимает строку в json-формате
      def dispatch(client, data)
        message = validate! data

        case message[:source]
        when :client
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
#            raise UserNotFound unless @ws.store[:clients].has_key? client
            @ws.close client

          when :update
#            raise UserNotFound unless @ws.store[:clients].has_key? client
            server.welcome client

          when :broadcast
#            raise UserNotFound unless @ws.store[:clients].has_key? client
            server.broadcast client, data[:params][:message]

          when :private
#            raise UserNotFound unless @ws.store[:clients].has_key? client
            server.private client, data[:params][:recipient], data[:params][:message]
          end
          
        when :server
          case message[:action]
          when :hello
            @ws.send client, data
            
          when :welcome
            @ws.send client, data

          when :error
            @ws.send client, data

          when :add_user
            @ws.broadcast client, data

          when :del_user
            @ws.broadcast client, data

          when :broadcast
            @ws.broadcast client, data

          when :private
            raise UserNotFound unless @ws.store[:clients].has_value? data[:params][:recipient]
            target_ws = @ws.store[:clients].key data[:params][:recipient]
            data[:params].delete :recipient
            @ws.send target_ws, data
          end
        end
      end
    end
  end
end
