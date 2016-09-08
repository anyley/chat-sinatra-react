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
  let(:srv_broadcast_params) { { timestamp: 1471935709105, sender: 'John Doe', message: 'My name John Doe' } }

  # valid client actions
  let(:login_action)     { { source: "client", type: "login",     params: username_params } }
  let(:logout_action)    { { source: "client", type: "logout" } }
  let(:update_action)    { { source: "client", type: "update" } }
  let(:broadcast_action) { { source: "client", type: "broadcast", params: { message: "hi all" } } }
  let(:private_action)   { { source: "client", type: "private",   params: { sender:  "John Doe",
                                                                            message: "Hi John!" } } }

  # valid server actions
  let(:hello_action)     { { source: "server", type: "hello" } }
  let(:welcome_action)   { { source: "server", type: "welcome",   params: { userlist: [], username: 'user-1' } } }
  let(:error_action)     { { source: "server", type: "error",     params: { message: 'Имя занято' } } }
  let(:add_user_action)  { { source: "server", type: "add_user",  params: username_params } }
  let(:del_user_action)  { { source: "server", type: "del_user",  params: username_params } }
  let(:broadcast_action) { { source: "server", type: "broadcast", params: srv_broadcast_params } }
  let(:private_action)   { { source: "server", type: "private",   params: { timestamp: 1471935709105,
                                                                            sender:    "John Doe",
                                                                            recipient: "user_2",
                                                                            message:   'My name John Doe' } } }

  # incorrect server actions
  let(:bad_add_user_action)  { { source: "server", type: "add_user" } }
  let(:bad_del_user_action)  { { source: "server", type: "del_user" } }
  let(:bad_broadcast_action) { { source: "server", type: "broadcast" } }
  let(:bad_private_action)   { { source: "server", type: "private" } }

  # incorrect client actions
  let(:bad_login_action)     { { source: "client", type: "login" } }
  let(:bad_broadcast_action) { { source: "client", type: "send_broadcast" } }
  let(:bad_private_action)   { { source: "client", type: "send_private" } }

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
        let(:bad_source) { { source: "other", type: "login", params: { username: "John Doe" } } }

        it 'raise exception Protocol::BadSource' do
          expect { protocol.validate! bad_source }.to raise_error Protocol::BadSource
        end
      end
      context 'when message is valid' do
        let(:input_message) { { source: "client", type: "login",
                                 params: { username: "John Doe" } } }
        let(:output_message) {{ source: :client, type: :login,
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

      context 'when it has an incorrect :type' do
        let(:bad_client_action) { { source: "client", type: "bad", params: { username: "John Doe" } } }

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

      context 'when it has an incorrect :type' do
        let(:bad_server_action) { { source: "server", type: "bad", params: { username: "John Doe" } } }

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

      it 'calls protocol.server.hello type' do
        expect(protocol.server).to receive(:hello).with(noname_client)
        protocol.handle noname_client, :open
      end
    end

    # TODO: написать тесты по обработке клиентских сообщений
    context 'when event type is :message' do
      before do
        server.store[:clients][named_client] = { username: 'user 2' }
      end
    end

    context 'when event type is :close' do
      before do
        server.store[:clients][noname_client.hash] = { ws: noname_client, username: nil }
        server.store[:clients][named_client.hash] = { ws: named_client, username: 'user 2' }
      end

      it "calls server action del_user" do
        expect(protocol.server).to receive(:del_user)
        protocol.handle named_client.hash, :close
      end

      it 'calls main server API method del_client' do
        expect(protocol.ws).to receive(:del_client)
        protocol.handle named_client.hash, :close
      end
    end
  end

  describe '.dispatch type' do
    before do
      server.store[:clients][noname_client.hash] = { ws: noname_client, username: nil }
      server.store[:clients][named_client.hash] = { ws: named_client, username: 'user 2' }
    end

    it 'calls validate! method' do
      expect(protocol).to receive(:validate!).with(hello_action).and_call_original
      protocol.dispatch noname_client.hash, hello_action
    end

    it "raise BadSource unless source type :server" do
      expect {
        protocol.dispatch noname_client.hash, login_action
      }.to raise_error Protocol::BadSource
    end

    it 'calls WebSocket Server API method :send when :hello action type' do
      expect(protocol.ws).to receive(:send)
      protocol.dispatch named_client, hello_action
    end

    it 'calls WebSocket Server API method :send when :welcome action type' do
      expect(protocol.ws).to receive(:send)
      protocol.dispatch named_client, welcome_action
    end

    it 'calls WebSocket Server API method :send when :error action type' do
      expect(protocol.ws).to receive(:send)
      protocol.dispatch named_client, error_action
    end

    context "when action type is :add_user " do
      it 'calls WSS API method :add_client' do
        expect(protocol.ws).to receive(:add_client)
        protocol.dispatch named_client.hash, add_user_action
      end

      it 'calls :welcome server action' do
        expect(protocol.server).to receive(:welcome)
        protocol.dispatch named_client.hash, add_user_action
      end

      it 'calls WSS API method :broadcast' do
        expect(protocol.ws).to receive(:broadcast)
        protocol.dispatch named_client.hash, add_user_action
      end
    end


    it 'calls WSS API method :broadcast when :del_user action type' do
      expect(protocol.ws).to receive(:broadcast)
      protocol.dispatch named_client.hash, add_user_action
    end

    it 'calls WSS API method :broadcast when :broadcast action type' do
      expect(protocol.ws).to receive(:broadcast)
      protocol.dispatch named_client.hash, add_user_action
    end

    context "when action type is :private " do
      it 'raise UserNotFound if recipient not found on server' do
        expect {
          protocol.dispatch named_client.hash, private_action
        }.to raise_error Protocol::UserNotFound
      end

      it 'calls WSS API method :send twice' do
        expect(protocol.ws).to receive(:send).twice
        protocol.dispatch named_client, {
            source: :server,
            type:   :private,
            params: {
                timestamp: 1471935709105,
                sender:    "John Doe",
                recipient: "user 2",
                message:   'My name John Doe'
            }
        }
      end
    end
  end
end


