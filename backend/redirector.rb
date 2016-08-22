require 'sinatra/base'


module Chat
  class Redirector < Sinatra::Base
    # перенаправляем случайные запросы на frontend
    get '*' do
      redirect ENV['REACT_URL'], 301
    end
  end
end
