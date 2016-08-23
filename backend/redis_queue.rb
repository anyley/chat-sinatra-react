module Chat
  # Реализована публикация данных в очередь
  # и обработки событий redis для извлечения данных из очереди
  class RedisQueue
    REDIS_CHANNEL = ENV["REDIS_CHAT_CHANNEL"]

    def initialize(websocket_server)
      @ws           = websocket_server
      uri           = URI.parse(ENV["REDIS_URL"])
      @redis_writer = Redis.new(host: uri.host, port: uri.port, password: uri.password)

      # Параллельный поток для приема событий редиса
      Thread.new do
        @redis_listener = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        @redis_listener.subscribe(REDIS_CHANNEL) do |on|
          # вытаскиваем из очереди Redis сообщения и рассылаем клиентам
          on.message do |channel, msg|
            puts "Channel: #{channel}, #{msg}"
            # broadcast-им сообщения из очереди websocket-клиентам
            @ws.broadcast(JSON.parse(msg, symbolize_names: true))
          end
        end
      end
    end

    def << (data)
      puts 'Publish message via RedisQueue'
      # помещаем сообщение в очередь Redis
      @redis_writer.publish(REDIS_CHANNEL, JSON.generate(data))
    end
  end
end
