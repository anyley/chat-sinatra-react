require 'erb'

module Chat
  module Plugin
    def self.href_maker(string)
      string.gsub /(https?:\/\/[\S]+)/, '<a href="\1">\1</a>'
    end
  end
end

