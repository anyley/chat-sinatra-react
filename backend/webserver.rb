require 'sinatra/base'


module Chat
  class WebServer < Sinatra::Base
    get '/:file.js' do
      send_file "./public/#{params[:file]}.js", :disposition => 'inline'
    end

    get '/' do
      erb :index
    end
  end
end
