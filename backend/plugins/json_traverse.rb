require 'json'

module ChatServer
  module Plugins
    def self.json(val, key=nil, &block)
      puts "json: #{key}: #{val}"
      h = JSON.parse(val)
      h = Plugins.traverse h, &block
      JSON.generate(h)
    end

    def self.traverse(val, key=nil, &block)
      puts "traverse: #{key}: #{val}"
      return val unless block

      val.each do |k, v|
        if v.is_a? Hash
          val[k] = Plugins.traverse(v, k, &block)
        elsif v.is_a? Array
          val[k] = v.map! { |item| yield(item) }
        else
          puts "yield: #{k}: #{v}"
          val[k] = yield(v, k)
        end
      end
    end
  end
end
