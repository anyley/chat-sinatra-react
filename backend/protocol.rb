module Chat
  module Protocol
    public
    # MESSAGE_FORMAT =
    #   :src  = :server | :client
    #   :cmd  = CLIENT_COMMANDS_FORMAT | SERVER_COMMANDS_FORMAT
    #   :data = соответственно по заданным ниже форматам
    MESSAGE_FORMAT  = [:source, :command, :params]

    #    [open]
    #    :hello ->
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
    #     [close]
    #     if user exists then :del_user ==>

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

    class UnknownAction < Exception
    end
    class Unknown < Exception
    end

    class BadSourceType < Exception
    end
    class BadCommandType < Exception
    end
    class BadCommandParameters < Exception
    end
    class BadMessageFormat < Exception
    end

    # @clients = {}

    def self.validate(message)
      # сообщение н едолжно быть nil
      raise Unknown if message.nil?

      # сообщение должно содержать обязательные параметры
      unless MESSAGE_FORMAT == MESSAGE_FORMAT & message.keys
        raise Unknown
      end

      message_source = message[:source].to_sym

      # сообщение должно быть от валидного источника
      unless COMMAND_FORMATS.has_key? message_source
        raise BadSourceType
      end

      message_command = message[:command].to_sym
      message_params  = message[:params]

      # находим список валидных команд для источника сообщения
      format_commands = COMMAND_FORMATS[message_source]
      # сообщение должно содержать релевантную команду от источника
      unless format_commands.has_key? message_command
        raise BadCommandType
      end

      # находим формат параметров
      format_params = format_commands[message_command]

      # проверка на наличие обязательных параметров для команды сообщения
      unless format_params == format_params & message_params.keys
        raise BadCommandParameters
      end

      true
    end


    def self.handleEvent(event, args)
      p args.keys
      store = args[:store]
      case event
        when :open
          store[:clients][] = { name: nil }
        when :message
          dispatch JSON.parse(data)
        when :close
          store[:clients].delete ws
        else
          raise UnknownAction
      end
    end


    # принимает строку в json-формате
    def self.dispatch(message=nil)
      validate message

      # message = JSON.parse message, symbolize_names: true
      case message[:src]
        when :client
          case message[:cmd]
            when :login
              puts message[:cmd]
            when :logout
              puts message[:cmd]
            when :get_user_list
              puts message[:cmd]
            when :get_chat_log
              puts message[:cmd]
            when :message
              puts message[:cmd]
            when :delete
              puts message[:cmd]
            when :change
              puts message[:cmd]
          end

        when :server
          case message[:cmd]
            when :hello
              puts message[:cmd]
            when :welcome
              puts message[:cmd]
            when :broadcast
              puts message[:cmd]
            when :user_list
              puts message[:cmd]
            when :chat_log
              puts message[:cmd]
            when :delete
              puts message[:cmd]
            when :change
              puts message[:cmd]
          end
      end

    rescue Protocol::Unknown
      puts '*** Protocol::Unknown'
    rescue Protocol::BadClientCommandType
      puts '*** Protocol::BadClientCommandType'
    rescue Protocol::BadServerCommandType
      puts '*** Protocol::BadServerCommandType'
    end
  end
end
