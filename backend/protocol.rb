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

      MESSAGE_FORMAT  = [:source, :type]

      # TODO: добавить в протокол подтверждение прочтения личного сообщения
      ACTIONS_FORMATS = {
        client: {
          login:     [:username],
          logout:    [],
          update:    [],
          send_broadcast: [:message],
          send_private:   [:recipient, :message]
        },
        server: {
          hello:     [],
          welcome:   [:userlist, :username],
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

        message_action = message[:type].to_sym
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
        {source: message_source, type: message_action, params: message_params}
      end

      
      # Обработчик сообщений поступающих через websocket
      def handle(wsh, event, data = '{}')
        data = JSON.parse(data, symbolize_names: true)

        case event
        when :open
          server.hello wsh

        when :message
          message = validate! data
          raise BadSource if message[:source] != :client

          case message[:type]
          when :login
            username = data[:params][:username]
            if @ws.has_username? username
              server.error wsh, 'Это имя занято'
            else
              server.add_user wsh, username
            end
            
          when :logout
            @ws.close wsh
            
          when :update
            server.welcome wsh
            
          when :send_broadcast
            server.broadcast wsh, data[:params][:message]
            
          when :send_private
            server.private wsh, data[:params][:recipient], data[:params][:message]
          end

        when :close
          server.del_user wsh, @ws.username_by_wsh(wsh)
          @ws.del_client wsh
        else
          raise UnknownEvent
        end
      end


      # Dispatch server actions
      def dispatch(client, data)
        message = validate! data
        raise BadSource if message[:source] != :server

        case message[:type]
        when :hello, :welcome, :error
          @ws.send client, data
          
        when :add_user
          @ws.add_client client, data[:params][:username]
          server.welcome client
          @ws.broadcast client, data, false

        when :del_user
          @ws.broadcast client, data, false
          
        when :broadcast
          @ws.broadcast client, data, true
          
        when :private
          # Выбросит исключение, если получателя нет в списке пользователей
          raise UserNotFound unless @ws.has_username? data[:params][:recipient]

          # Ищем websocket получателя
          target_ws = @ws.wsh_by_username data[:params][:recipient]
          # Отправляем приватное сообщение получателю
          @ws.send target_ws, data
          # Эхо-подтверждение об успешной отправки
          @ws.send client, data
        end
      end
    end
  end
end
