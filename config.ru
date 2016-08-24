require './backend/server'
require './backend/redirector'
require 'sinatra'

require 'dotenv'
Dotenv.load './.env'

enable :logging

use Chat::Server
run Chat::Redirector.new
