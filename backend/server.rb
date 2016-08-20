require 'sinatra/base'

module ChatDemo
  class Server < Sinatra::Base
    get "/" do
      redirect :"http://localhost:8080/index.html"
    end

    get "/assets/js/application.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"application.js"
    end
  end
end
