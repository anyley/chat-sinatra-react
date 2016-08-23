module Chat
  # Локальная реализация рассылки сообщений
  # без очередей, без redis, rabbitmq и прочих
  class LocalQueue
    # Как только сообщение поступает от клиента
    # оно сразу же бродкастится всем остальным
    # подключенным к этому же серверу
    def publish(data, channel=nil)
      puts 'Publish message via LocalQueue'
      p JSON.parse(data, symbolize_names: true)
      broadcast(data)
    end
  end
end
