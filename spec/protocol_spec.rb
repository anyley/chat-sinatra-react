require 'rspec'
require './backend/protocol'
include Chat

describe Chat::Protocol do
  describe '.validate message' do
    context 'from either Client or Server' do
      context "when it has 'nil'" do
        let(:nil_msg) { nil }
        it 'raise exception' do
          expect { Protocol.validate nil_msg }.to raise_error Protocol::Unknown
        end
      end

      context 'when it has an incorrect :source' do
        let(:bad_source) { { source: "other", command: "login", params: { username: "John Doe" } } }

        it 'raise exception' do
          expect { Protocol.validate bad_source }.to raise_error Protocol::BadSourceType
        end
      end
    end

    context 'from Client' do
      context 'when it is correct' do
        let(:login_cmd) { { source: "client", command: "login", params: { username: "John Doe" } } }
        let(:logout_cmd) { { source: "client", command: "logout", params: {} } }
        let(:update_cmd) { { source: "client", command: "update", params: {} } }
        let(:broadcast_cmd) { { source: "client", command: "broadcast", params: { message: "hi all" } } }
        let(:private_cmd) { { source: "client", command: "private",
                              params: { username: "John Doe", message: "Hi John!" } } }

        it 'then return nil' do
          expect(Protocol.validate login_cmd).to be_truthy
          expect(Protocol.validate logout_cmd).to be_truthy
          expect(Protocol.validate update_cmd).to be_truthy
          expect(Protocol.validate broadcast_cmd).to be_truthy
          expect(Protocol.validate private_cmd).to be_truthy
        end
      end

      context 'when it has an incorrect :command' do
        let(:bad_client_cmd) { { source: "client", command: "bad", params: { username: "John Doe" } } }

        it 'raise exception' do
          expect { Protocol.validate bad_client_cmd }.to raise_error Protocol::BadCommandType
        end
      end

      context 'when it has an incorrect :params' do
        let(:login_cmd) { { source: "client", command: "login", params: {} } }
        let(:broadcast_cmd) { { source: "client", command: "broadcast", params: {} } }
        let(:private_cmd) { { source: "client", command: "private", params: {} } }

        it 'raise exception' do
          expect { Protocol.validate login_cmd }.to raise_error Protocol::BadCommandParameters
          expect { Protocol.validate broadcast_cmd }.to raise_error Protocol::BadCommandParameters
          expect { Protocol.validate private_cmd }.to raise_error Protocol::BadCommandParameters
        end
      end
    end

    context 'from Server' do
      context 'when it is correct' do
        let(:hello_cmd) { { source: "server", command: "hello", params: { client: nil } } }
        let(:welcome_cmd) { { source: "server", command: "welcome", params: { client: nil } } }
        let(:error_cmd) { { source: "server", command: "error", params: { client:  nil,
                                                                          message: 'Имя занято' } } }
        let(:add_user_cmd) { { source: "server", command: "add_user", params: { username: "John Doe" } } }
        let(:del_user_cmd) { { source: "server", command: "del_user", params: { username: "John Doe" } } }
        let(:broadcast_cmd) { { source: "server", command: "broadcast", params: { timestamp: 1471935709105,
                                                                                  username:  "John Doe",
                                                                                  message:   'My name John Doe' } } }
        let(:private_cmd) { { source: "server", command: "private", params: { timestamp: 1471935709105,
                                                                              sender:    "John Doe",
                                                                              recipient: "user_2",
                                                                              message:   'My name John Doe' } } }
        it 'then return nil' do
          expect(Protocol.validate hello_cmd).to be_truthy
          expect(Protocol.validate welcome_cmd).to be_truthy
          expect(Protocol.validate error_cmd).to be_truthy
          expect(Protocol.validate add_user_cmd).to be_truthy
          expect(Protocol.validate del_user_cmd).to be_truthy
          expect(Protocol.validate broadcast_cmd).to be_truthy
          expect(Protocol.validate private_cmd).to be_truthy
        end
      end

      context 'when it has an incorrect :command' do
        let(:bad_server_cmd) { { source: "server", command: "bad", params: { username: "John Doe" } } }

        it 'raise exception' do
          expect { Protocol.validate bad_server_cmd }.to raise_error Protocol::BadCommandType
        end
      end

      context 'when it has an incorrect :params 2' do
        let(:hello_cmd) { { source: "server", command: "hello", params: {} } }
        let(:welcome_cmd) { { source: "server", command: "welcome", params: {} } }
        let(:error_cmd) { { source: "server", command: "error", params: {} } }
        let(:add_user_cmd) { { source: "server", command: "add_user", params: {} } }
        let(:del_user_cmd) { { source: "server", command: "del_user", params: {} } }
        let(:broadcast_cmd) { { source: "server", command: "broadcast", params: {} } }
        let(:private_cmd) { { source: "server", command: "private", params: {} } }

        it 'raise exception' do
          expect { Protocol.validate hello_cmd }.to raise_error Protocol::BadCommandParameters
          expect { Protocol.validate welcome_cmd }.to raise_error Protocol::BadCommandParameters
          expect { Protocol.validate error_cmd }.to raise_error Protocol::BadCommandParameters
          expect { Protocol.validate add_user_cmd }.to raise_error Protocol::BadCommandParameters
          expect { Protocol.validate del_user_cmd }.to raise_error Protocol::BadCommandParameters
          expect { Protocol.validate broadcast_cmd }.to raise_error Protocol::BadCommandParameters
          expect { Protocol.validate private_cmd }.to raise_error Protocol::BadCommandParameters
        end
      end
    end
  end
end