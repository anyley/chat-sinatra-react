require 'erb'

module ChatServer
  module Plugins
    def self.href_maker(val, key=nil, find_key=nil, &block)
      puts "href: #{key}: #{val}"
      if key == find_key
        val = val.gsub /(https?:\/\/[\S]+)/, '<a href="\1">\1</a>'
        val = yield(val, key) if block
      end
      val
    end
  end
end

