# coding: utf-8
require './backend/server_actions'

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

      def initialize(ws)
        @ws = ws
        @server = ServerActions.new self
        @message_list = {}
        @current_message_id = 1
      end

      def server
        @server
      end

      MESSAGE_FORMAT  = [:source, :action]

      # TODO: добавить в протокол подтверждение прочтения личного сообщения
      ACTIONS_FORMATS = {
        client: {
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
          broadcast: [:timestamp, :sender, :message],
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
        message_params = message[:params] || {}
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

      
      # Обработчик сообщений поступающих через websocket
      def handle(client, event, data = '{}')
        data = JSON.parse(data, symbolize_names: true)

        case event
        when :open
          server.hello client

        when :message
          message = validate! data
          raise BadSource if message[:source] != :client

          case message[:action]
          when :login
            username = data[:params][:username]
            if @ws.store[:clients].has_value? username
              server.error client, 'Это имя занято'
            else
              @ws.save_client client, username
              server.welcome client
              server.add_user client, username
            end
            
          when :logout
            @ws.close client
            
          when :update
            server.welcome client
            
          when :broadcast
            server.broadcast client, data[:params][:message]
            
          when :private
            server.private client, data[:params][:recipient], data[:params][:message]
          end

        when :close
          server.del_user client, @ws.username_by_socket(client)
          @ws.del_client client

        else
          raise UnknownEvent
        end
      end


      # Dispatch server actions
      def dispatch(client, data)
        message = validate! data
        raise BadSource if message[:source] != :server

        case message[:action]
        when :hello, :welcome, :error
          @ws.send client, data
          
        when :add_user, :del_user
          @ws.broadcast client, data, false
          
        when :broadcast
          @ws.broadcast client, data, true
          
        when :private
          # Выбросит исключение, если получателя нет в списке пользователей
          raise UserNotFound unless @ws.store[:clients].has_value? data[:params][:recipient]

          # Ищем websocket получателя
          target_ws = @ws.store[:clients].key data[:params][:recipient]
          # Отправляем приватное сообщение получателю
          @ws.send target_ws, data
          # Эхо-подтверждение об успешной отправки
          @ws.send client, data
        end
      end
    end
  end
end
