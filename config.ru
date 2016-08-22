require './backend/server'
require './backend/redirector'
require 'sinatra'

require 'dotenv'
Dotenv.load

enable :logging

use Chat::Server
run Chat::Redirector.new
