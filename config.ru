require './backend/server'
require './backend/chat_backend'

use ChatDemo::ChatBackend

run ChatDemo::Server
