require './backend/server'
require './backend/redirector'
require './backend/webserver'
require 'sinatra'

require 'dotenv'
Dotenv.load './.env'

enable :logging

use Chat::Server
#if ENV['RACK_ENV'] == 'production'
  run Chat::WebServer.new
#else
#  run Chat::Redirector.new
#end