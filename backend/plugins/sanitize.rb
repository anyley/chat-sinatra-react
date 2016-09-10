require 'erb'

module Chat
  module Plugin
    def self.sanitize(string)
      ERB::Util.html_escape(string)
    end
  end
end
