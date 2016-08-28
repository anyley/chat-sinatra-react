# coding: utf-8
require 'dotenv'
Dotenv.load './.env'

require 'rspec'
require 'json'
require 'spec_helper'
require './backend/server'
require './backend/protocol'
include Chat


# Заглушка для Faye::WebSocket
class CustomWebSocket
  def send(data)
  end
end


describe Chat::Protocol::Simple do
  let(:named_client)  { CustomWebSocket.new }
  let(:noname_client) { CustomWebSocket.new }
  let(:username_params) { { username: "John Doe" } }
  let(:srv_broadcast_params) { { timestamp: 1471935709105, username: 'John Doe', message: 'My name John Doe' } }

  # valid client actions
  let(:login_action)     { { source: "client", action: "login",     params: username_params } }
  let(:logout_action)    { { source: "client", action: "logout" } }
  let(:update_action)    { { source: "client", action: "update" } }
  let(:broadcast_action) { { source: "client", action: "broadcast", params: { message: "hi all" } } }
  let(:private_action)   { { source: "client", action: "private",   params: { username: "John Doe",
                                                                              message:  "Hi John!" } } }

  # valid server actions
  let(:hello_action)     { { source: "server", action: "hello" } }
  let(:welcome_action)   { { source: "server", action: "welcome",   params: { userlist: [] } } }
  let(:error_action)     { { source: "server", action: "error",     params: { message: 'Имя занято' } } }
  let(:add_user_action)  { { source: "server", action: "add_user",  params: username_params } }
  let(:del_user_action)  { { source: "server", action: "del_user",  params: username_params } }
  let(:broadcast_action) { { source: "server", action: "broadcast", params: srv_broadcast_params } }
  let(:private_action)   { { source: "server", action: "private",   params: { timestamp: 1471935709105,
                                                                              sender:    "John Doe",
                                                                              recipient: "user_2",
                                                                              message:   'My name John Doe' } } }

  # incorrect server actions
  let(:bad_add_user_action)  { { source: "server", action: "add_user" } }
  let(:bad_del_user_action)  { { source: "server", action: "del_user" } }
  let(:bad_broadcast_action) { { source: "server", action: "broadcast" } }
  let(:bad_private_action)   { { source: "server", action: "private" } }

  # incorrect client actions
  let(:bad_login_action)     { { source: "client", action: "login" } }
  let(:bad_broadcast_action) { { source: "client", action: "broadcast" } }
  let(:bad_private_action)   { { source: "client", action: "private" } }

  let(:server) { Chat::Server.new(nil) }
  let(:protocol) { server.protocol }

  before do
  end

  describe '.validate!' do 
    context 'from either Client or Server' do
      context "when message is nil" do
        let(:nil_msg) { nil }

        it 'raise exception Protocol::Unknown' do
          expect { protocol.validate! nil_msg }.to raise_error Protocol::Unknown
        end
      end

      context 'when it has an incorrect :source' do
        let(:bad_source) { { source: "other", action: "login", params: { username: "John Doe" } } }

        it 'raise exception Protocol::BadSource' do
          expect { protocol.validate! bad_source }.to raise_error Protocol::BadSource
        end
      end

      context 'when message is valid' do
        let (:input_message) { { source: "client", action: "login",
                                 params: { username: "John Doe" } } }
        let (:output_message) {{ source: :client, action: :login,
                                 params: { username: "John Doe" } } }
        it 'converts message values to :sym and return new hash' do
          expect( protocol.validate! input_message ).to be == output_message
        end
      end

    end

    context 'from Client' do
      context 'when it is correct' do

        it 'returns true' do
          expect(protocol.validate! login_action    ).to be_truthy
          expect(protocol.validate! logout_action   ).to be_truthy
          expect(protocol.validate! update_action   ).to be_truthy
          expect(protocol.validate! broadcast_action).to be_truthy
          expect(protocol.validate! private_action  ).to be_truthy
        end
      end

      context 'when it has an incorrect :action' do
        let(:bad_client_action) { { source: "client", action: "bad", params: { username: "John Doe" } } }

        it 'raise exception Protocol::BadAction' do
          expect { protocol.validate! bad_client_action }.to raise_error Protocol::BadAction
        end
      end

      context 'when it has an incorrect :params' do
        it 'raise exception Protocol::BadParameters' do
          expect { protocol.validate! bad_login_action     }.to raise_error Protocol::BadParameters
          expect { protocol.validate! bad_broadcast_action }.to raise_error Protocol::BadParameters
          expect { protocol.validate! bad_private_action   }.to raise_error Protocol::BadParameters
        end
      end
    end
    

    context 'from Server' do
      context 'when it is correct' do
        it 'returns true' do
          expect(protocol.validate! hello_action    ).to be_truthy
          expect(protocol.validate! welcome_action  ).to be_truthy
          expect(protocol.validate! error_action    ).to be_truthy
          expect(protocol.validate! add_user_action ).to be_truthy
          expect(protocol.validate! del_user_action ).to be_truthy
          expect(protocol.validate! broadcast_action).to be_truthy
          expect(protocol.validate! private_action  ).to be_truthy
        end
      end

      context 'when it has an incorrect :action' do
        let(:bad_server_action) { { source: "server", action: "bad", params: { username: "John Doe" } } }

        it 'raise exception Protocol::BadAction' do
          expect { protocol.validate! bad_server_action }.to raise_error Protocol::BadAction
        end
      end

      context 'when it has an incorrect :params' do
        it 'raise exception Protocol::BadParameters' do
          expect { protocol.validate! bad_add_user_action  }.to raise_error Protocol::BadParameters
          expect { protocol.validate! bad_del_user_action  }.to raise_error Protocol::BadParameters
          expect { protocol.validate! bad_broadcast_action }.to raise_error Protocol::BadParameters
          expect { protocol.validate! bad_private_action   }.to raise_error Protocol::BadParameters
        end
      end
    end
  end

  describe '.handle' do
    context "when called with unknown event type" do
      it 'raise UnknownEvent' do
        expect {
          protocol.handle named_client, :bad_action
        }.to raise_error Protocol::UnknownEvent
      end
    end

    context 'when event type is :open' do
      # it 'calls ws_server.save_client method' do
      #   expect(server).to receive(:save_client)
      #                      .with(noname_client, { username: nil })
      #                      .and_call_original
        
      #   protocol.handle noname_client, :open
      # end

      it 'calls protocol.server.hello action' do
        expect(protocol.server).to receive(:hello).with(noname_client)
        protocol.handle noname_client, :open
      end
    end

    context 'when event type is :message' do
      before do
        server.store[:clients][named_client] = { username: 'user 2' }
      end
      
      it 'calls protocol.dispatch method' do
        expect(protocol).to receive(:dispatch).with(named_client, {})
        protocol.handle named_client, :message
      end
    end

    context 'when event type is :close' do
      before do
        server.store[:clients][noname_client] = { username: nil }
        server.store[:clients][named_client] = { username: 'user 2' }
      end
      
#      context 'when client has username' do
        it "calls dispatch method with action :del_user" do
          expect(protocol.server).to receive(:del_user).with(named_client, {username: "user 2"})
          protocol.handle named_client, :close
        end
#      end
      
      # context 'when client not have username' do
      #   it "passes the call dispatch method" do
      #     expect(protocol).not_to receive(:dispatch)
      #     protocol.handle noname_client, :close
      #   end
      # end

      it 'calls server.del_client method' do
        expect(server).to receive(:del_client)
        protocol.handle named_client, :close
      end
    end
  end

  describe '.dispatch action' do
    it 'calls validate! method' do
      expect(protocol).to receive(:validate!).with(hello_action).and_call_original
      protocol.dispatch noname_client, hello_action
    end

    context 'when message :source is :server' do
      context 'when action is :hello' do
        it 'call @ws.send method' do
          expect(server).to receive(:send)
          protocol.dispatch noname_client, hello_action
        end
      end
    end
    
  end
end


