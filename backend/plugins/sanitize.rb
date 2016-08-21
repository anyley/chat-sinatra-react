require 'erb'

module ChatServer
  module Plugins
    def self.sanitize(val, key=nil, &block)
      puts "sanitize: #{key}: #{val}"
      val = ERB::Util.html_escape(val)
      val = yield(val, key) if block
      val
    end
  end
end
