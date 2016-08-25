require 'dotenv'
Dotenv.load './.env'

require 'rspec'
require 'json'
require 'spec_helper'
require './backend/server'
# require './backend/protocol'
include Chat


server = protocol = nil

describe Chat::Protocol::Simple do
  before {
    server   = Chat::Server.new(nil)
    protocol = Chat::Protocol::Simple.new(server)
  }
  describe '#validate message' do
    context 'from either Client or Server' do
      context "when it has 'nil'" do
        let(:nil_msg) { nil }

        it 'raise exception' do
          expect { protocol.validate nil_msg }.to raise_error Protocol::Unknown
        end
      end

      context 'when it has an incorrect :source' do
        let(:bad_source) { { source: "other", command: "login", params: { username: "John Doe" } } }

        it 'raise exception' do
          expect { protocol.validate bad_source }.to raise_error Protocol::BadSource
        end
      end
    end

    context 'from Client' do
      context 'when it is correct' do
        let(:login_cmd)     { { source: "client", command: "login",
                                params: { username: "John Doe" } } }
        let(:logout_cmd)    { { source: "client", command: "logout",
                                params: {} } }
        let(:update_cmd)    { { source: "client", command: "update",
                                params: {} } }
        let(:broadcast_cmd) { { source: "client", command: "broadcast",
                                params: { message: "hi all" } } }
        let(:private_cmd)   { { source: "client", command: "private",
                                params: { username: "John Doe",
                                          message:  "Hi John!" } } }

        it 'then return nil' do
          expect(protocol.validate login_cmd    ).to be_truthy
          expect(protocol.validate logout_cmd   ).to be_truthy
          expect(protocol.validate update_cmd   ).to be_truthy
          expect(protocol.validate broadcast_cmd).to be_truthy
          expect(protocol.validate private_cmd  ).to be_truthy
        end
      end

      context 'when it has an incorrect :command' do
        let(:bad_client_cmd) { { source: "client", command: "bad", params: { username: "John Doe" } } }

        it 'raise exception' do
          expect { protocol.validate bad_client_cmd }.to raise_error Protocol::BadCommand
        end
      end

      context 'when it has an incorrect :params' do
        let(:login_cmd)     { { source: "client", command: "login",     params: {} } }
        let(:broadcast_cmd) { { source: "client", command: "broadcast", params: {} } }
        let(:private_cmd)   { { source: "client", command: "private",   params: {} } }

        it 'raise exception' do
          expect { protocol.validate login_cmd     }.to raise_error Protocol::BadParameters
          expect { protocol.validate broadcast_cmd }.to raise_error Protocol::BadParameters
          expect { protocol.validate private_cmd   }.to raise_error Protocol::BadParameters
        end
      end
    end

    context 'from Server' do
      context 'when it is correct' do
        let(:hello_cmd)     { { source: "server", command: "hello",
                                params: { client: nil } } }
        let(:welcome_cmd)   { { source: "server", command: "welcome",
                                params: { client: nil } } }
        let(:error_cmd)     { { source: "server", command: "error",
                                params: { client:  nil,
                                          message: 'Имя занято' } } }
        let(:add_user_cmd)  { { source: "server", command: "add_user",
                                params: { username: "John Doe" } } }
        let(:del_user_cmd)  { { source: "server", command: "del_user",
                                params: { username: "John Doe" } } }
        let(:broadcast_cmd) { { source: "server", command: "broadcast",
                                params: { timestamp: 1471935709105,
                                          username:  "John Doe",
                                          message:   'My name John Doe' } } }
        let(:private_cmd)   { { source: "server", command: "private",
                                params: { timestamp: 1471935709105,
                                          sender:    "John Doe",
                                          recipient: "user_2",
                                          message:   'My name John Doe' } } }
        it 'then return nil' do
          expect(protocol.validate hello_cmd    ).to be_truthy
          expect(protocol.validate welcome_cmd  ).to be_truthy
          expect(protocol.validate error_cmd    ).to be_truthy
          expect(protocol.validate add_user_cmd ).to be_truthy
          expect(protocol.validate del_user_cmd ).to be_truthy
          expect(protocol.validate broadcast_cmd).to be_truthy
          expect(protocol.validate private_cmd  ).to be_truthy
        end
      end

      context 'when it has an incorrect :command' do
        let(:bad_server_cmd) { { source: "server", command: "bad", params: { username: "John Doe" } } }

        it 'raise exception' do
          expect { protocol.validate bad_server_cmd }.to raise_error Protocol::BadCommand
        end
      end

      context 'when it has an incorrect :params 2' do
        let(:hello_cmd)     { { source: "server", command: "hello",     params: {} } }
        let(:welcome_cmd)   { { source: "server", command: "welcome",   params: {} } }
        let(:error_cmd)     { { source: "server", command: "error",     params: {} } }
        let(:add_user_cmd)  { { source: "server", command: "add_user",  params: {} } }
        let(:del_user_cmd)  { { source: "server", command: "del_user",  params: {} } }
        let(:broadcast_cmd) { { source: "server", command: "broadcast", params: {} } }
        let(:private_cmd)   { { source: "server", command: "private",   params: {} } }

        it 'raise exception' do
          expect { protocol.validate hello_cmd     }.to raise_error Protocol::BadParameters
          expect { protocol.validate welcome_cmd   }.to raise_error Protocol::BadParameters
          expect { protocol.validate error_cmd     }.to raise_error Protocol::BadParameters
          expect { protocol.validate add_user_cmd  }.to raise_error Protocol::BadParameters
          expect { protocol.validate del_user_cmd  }.to raise_error Protocol::BadParameters
          expect { protocol.validate broadcast_cmd }.to raise_error Protocol::BadParameters
          expect { protocol.validate private_cmd   }.to raise_error Protocol::BadParameters
        end
      end
    end
  end

  describe '#handle' do
    client_1 = Object.new
    client_2 = Object.new

    context "when invoked with bad action" do
      it 'raise UnknownAction' do
        expect {
          protocol.handle client_1, :bad_action
        }.to raise_error Protocol::UnknownAction
      end
    end

    context 'with event :open' do
      it 'add client to store' do
        expect {
          protocol.handle client_1, :open
        }.to change { server.store[:clients].size }.by(1)
      end

      it 'invoke server.add_client' do
        expect( server.store[:clients] ).to be_empty
        expect( server ).to receive(:add_client).and_call_original.twice
        protocol.handle client_1, :open
        protocol.handle client_2, :open
        expect( server.store[:clients].size ).to be == 2
      end
    end

    context 'with event :close' do
      before {
        server.store[:clients][client_1] = { username: nil }
        server.store[:clients][client_2] = { username: 'user 2' }
      }

      it "dispatch :del_user if client has username" do
        expect( protocol ).to receive(:dispatch).once
        protocol.handle client_1, :close
        protocol.handle client_2, :close
      end

      it 'invoke server.del_client' do
        expect( server ).to receive(:del_client).and_call_original.twice
        protocol.handle client_1, :close
        protocol.handle client_2, :close
      end

      it 'remove socket from store[:clients]' do
        expect {
          protocol.handle client_1, :close
          protocol.handle client_2, :close
        }.to change { server.store[:clients].size }.by(-2)
      end
    end

    context 'with event :message' do
      it '' do
      end
    end

  end

end
