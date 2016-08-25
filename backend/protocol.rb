module Chat
  module Protocol
    class UnknownAction  < Exception; end
    class Unknown        < Exception; end
    class BadSource      < Exception; end
    class BadCommand     < Exception; end
    class BadParameters  < Exception; end

    class Simple
      def initialize(server)
        @server = server
      end

      # MESSAGE_FORMAT =
      #   :src  = :server | :client
      #   :cmd  = CLIENT_COMMANDS_FORMAT | SERVER_COMMANDS_FORMAT
      #   :data = соответственно по заданным ниже форматам
      MESSAGE_FORMAT  = [:source, :command, :params]

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
      COMMAND_FORMATS = {
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
              hello:     [:client],
              welcome:   [:client],
              error:     [:client, :message],
              add_user:  [:username],
              del_user:  [:username],
              broadcast: [:timestamp, :username, :message],
              private:   [:timestamp, :sender, :recipient, :message]
          }
      }


      def validate(message)
        # сообщение н едолжно быть nil
        raise Unknown if message.nil?

        # сообщение должно содержать обязательные параметры
        unless MESSAGE_FORMAT == MESSAGE_FORMAT & message.keys
          raise Unknown
        end

        message_source = message[:source].to_sym

        # сообщение должно быть от валидного источника
        unless COMMAND_FORMATS.has_key? message_source
          raise BadSource
        end

        message_command = message[:command].to_sym
        message_params  = message[:params]

        # находим список валидных команд для источника сообщения
        format_commands = COMMAND_FORMATS[message_source]
        # сообщение должно содержать релевантную команду от источника
        unless format_commands.has_key? message_command
          raise BadCommand
        end

        # находим формат параметров
        format_params = format_commands[message_command]

        # проверка на наличие обязательных параметров для команды сообщения
        unless format_params == format_params & message_params.keys
          raise BadParameters
        end

        # все ОК
        true
      end


      # Первичный обработчик сообщений поступающих через websocket
      def handle(client, event, data = '{}')
        data = JSON.parse(data, symbolize_names: true)

        case event
          when :open
            @server.add_client client, { username: nil }

          when :message
            dispatch client, data

          when :close
            unless @server.store[:clients][client][:username].nil?
              dispatch client, { source:  :server,
                                 command: :del_user,
                                 params:  { username: @server.store[:clients][client][:username] } }
            end
            @server.del_client client
          else
            raise UnknownAction
        end
      end


      # принимает строку в json-формате
      def dispatch(client, message = nil)
        validate message

        # message = JSON.parse message, symbolize_names: true
        case message[:src]
          when :client
            # let(:login_cmd)     { { source: "client", command: "login",
            #                         params: { username: "John Doe" } } }
            # let(:logout_cmd)    { { source: "client", command: "logout",
            #                         params: {} } }
            # let(:update_cmd)    { { source: "client", command: "update",
            #                         params: {} } }
            # let(:broadcast_cmd) { { source: "client", command: "broadcast",
            #                         params: { message: "hi all" } } }
            # let(:private_cmd)   { { source: "client", command: "private",
            #                         params: { username: "John Doe",
            #                                   message:  "Hi John!" } } }            case message[:cmd]
          when :login
            puts message[:cmd]
          when :logout
            puts message[:cmd]
          when :update
            puts message[:cmd]
          when :broadcast
            puts message[:cmd]
          when :private
            puts message[:cmd]

        end

        # let(:hello_cmd)     { { source: "server", command: "hello",
        #                         params: { client: nil } } }
        # let(:welcome_cmd)   { { source: "server", command: "welcome",
        #                         params: { client: nil } } }
        # let(:error_cmd)     { { source: "server", command: "error",
        #                         params: { client:  nil,
        #                                   message: 'Имя занято' } } }
        # let(:add_user_cmd)  { { source: "server", command: "add_user",
        #                         params: { username: "John Doe" } } }
        # let(:del_user_cmd)  { { source: "server", command: "del_user",
        #                         params: { username: "John Doe" } } }
        # let(:broadcast_cmd) { { source: "server", command: "broadcast",
        #                         params: { timestamp: 1471935709105,
        #                                   username:  "John Doe",
        #                                   message:   'My name John Doe' } } }
        # let(:private_cmd)   { { source: "server", command: "private",
        #                         params: { timestamp: 1471935709105,
        #                                   sender:    "John Doe",
        #                                   recipient: "user_2",
        #                                   message:   'My name John Doe' } } }          when :server
        case message[:cmd]
          when :hello
            puts message[:cmd]
          when :welcome
            puts message[:cmd]
          when :error
            puts message[:cmd]
          when :add_user
            puts message[:cmd]
          when :del_user
            puts message[:cmd]
          when :broadcast
            puts message[:cmd]
          when :private
            puts message[:cmd]
        end

      rescue Protocol::Unknown
        puts '*** Protocol::Unknown'
      rescue Protocol::BadCommand
        puts '*** Protocol::BadCommand'
      end
    end
  end
end
