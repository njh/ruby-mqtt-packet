# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet'

describe MQTT::Packet::Connect do
  describe "when serialising a packet" do
    it "should output the correct bytes for a packet with no flags" do
      packet = MQTT::Packet::Connect.new( :client_id => 'myclient' )
      expect(packet.to_s).to eq("\020\026\x00\x06MQIsdp\x03\x02\x00\x0f\x00\x08myclient")
    end

    it "should output the correct bytes for a packet with clean session turned off" do
      packet = MQTT::Packet::Connect.new(
        :client_id => 'myclient',
        :clean_session => false
      )
      expect(packet.to_s).to eq("\020\026\x00\x06MQIsdp\x03\x00\x00\x0f\x00\x08myclient")
    end

    context "protocol version 3.1.0" do
      it "should raise an exception when there is no client identifier" do
        expect {
          MQTT::Packet::Connect.new(:version => '3.1.0', :client_id => '').to_s
        }.to raise_error(
          'Client identifier too short while serialising packet'
        )
      end

      it "should raise an exception when the client identifier is too long" do
        expect {
          client_id = '0EB8D2FE7C254715B4467C5B2ECAD100'
          MQTT::Packet::Connect.new(:version => '3.1.0', :client_id => client_id).to_s
        }.to raise_error(
          'Client identifier too long when serialising packet'
        )
      end
    end

    context "protocol version 3.1.1" do
      it "should allow no client identifier" do
        packet = MQTT::Packet::Connect.new(
          :version => '3.1.1',
          :client_id => '',
          :clean_session => true
        )
        expect(packet.to_s).to eq("\020\014\x00\x04MQTT\x04\x02\x00\x0f\x00\x00")
      end

      it "should allow a 32 character client identifier" do
        client_id = '0EB8D2FE7C254715B4467C5B2ECAD100'
        packet = MQTT::Packet::Connect.new(
          :version => '3.1.1',
          :client_id => client_id,
          :clean_session => true
        )
        expect(packet.to_s).to eq("\x10,\x00\x04MQTT\x04\x02\x00\x0F\x00\x200EB8D2FE7C254715B4467C5B2ECAD100")
      end
    end

    it "should raise an exception if the keep alive value is less than 0" do
      expect {
        MQTT::Packet::Connect.new(:client_id => 'test', :keep_alive => -2).to_s
      }.to raise_error(
        'Invalid keep-alive value: cannot be less than 0'
      )
    end

    it "should output the correct bytes for a packet with a Will" do
      packet = MQTT::Packet::Connect.new(
        :client_id => 'myclient',
        :clean_session => true,
        :will_qos => 1,
        :will_retain => false,
        :will_topic => 'topic',
        :will_payload => 'hello'
      )
      expect(packet.to_s).to eq(
        "\x10\x24"+
        "\x00\x06MQIsdp"+
        "\x03\x0e\x00\x0f"+
        "\x00\x08myclient"+
        "\x00\x05topic\x00\x05hello"
      )
    end

    it "should output the correct bytes for a packet with a username and password" do
      packet = MQTT::Packet::Connect.new(
        :client_id => 'myclient',
        :username => 'username',
        :password => 'password'
      )
      expect(packet.to_s).to eq(
        "\x10\x2A"+
        "\x00\x06MQIsdp"+
        "\x03\xC2\x00\x0f"+
        "\x00\x08myclient"+
        "\x00\x08username"+
        "\x00\x08password"
      )
    end

    it "should output the correct bytes for a packet with everything" do
      packet = MQTT::Packet::Connect.new(
        :client_id => '12345678901234567890123',
        :clean_session => true,
        :keep_alive => 65535,
        :will_qos => 2,
        :will_retain => true,
        :will_topic => 'will_topic',
        :will_payload => 'will_message',
        :username => 'user0123456789',
        :password => 'pass0123456789'
      )
      expect(packet.to_s).to eq(
        "\x10\x5F"+ # fixed header (2)
        "\x00\x06MQIsdp"+ # protocol name (8)
        "\x03\xf6"+ # protocol level + flags (2)
        "\xff\xff"+ # keep alive (2)
        "\x00\x1712345678901234567890123"+ # client identifier (25)
        "\x00\x0Awill_topic"+ # will topic (12)
        "\x00\x0Cwill_message"+ # will message (14)
        "\x00\x0Euser0123456789"+ # username (16)
        "\x00\x0Epass0123456789"
      )  # password (16)
    end

    context 'protocol version 3.1.1' do
      it "should output the correct bytes for a packet with no flags" do
        packet = MQTT::Packet::Connect.new( :version => '3.1.1', :client_id => 'myclient' )
        expect(packet.to_s).to eq("\020\024\x00\x04MQTT\x04\x02\x00\x0f\x00\x08myclient")
      end
    end

    context 'an invalid protocol version number' do
      it "should raise a protocol exception" do
        expect {
          packet = MQTT::Packet::Connect.new( :version => 'x.x.x', :client_id => 'myclient' )
        }.to raise_error(
          ArgumentError,
          "Unsupported protocol version: x.x.x"
        )
      end
    end

  end

  describe "when parsing a simple 3.1.0 Connect packet" do
    let(:packet) do
      MQTT::Packet.parse(
        "\x10\x16\x00\x06MQIsdp\x03\x00\x00\x0a\x00\x08myclient"
      )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connect)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, false, false, false])
    end

    it "should set the Protocol Name of the packet correctly" do
      expect(packet.protocol_name).to eq('MQIsdp')
      expect(packet.protocol_name.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Protocol Level of the packet correctly" do
      expect(packet.protocol_level).to eq(3)
    end

    it "should set the Protocol version of the packet correctly" do
      expect(packet.version).to eq('3.1.0')
    end

    it "should set the Client Identifier of the packet correctly" do
      expect(packet.client_id).to eq('myclient')
      expect(packet.client_id.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Keep Alive timer of the packet correctly" do
      expect(packet.keep_alive).to eq(10)
    end

    it "should set not have the clean session flag set" do
      expect(packet.clean_session).to be_falsey
    end

    it "should set the the username field of the packet to nil" do
      expect(packet.username).to be_nil
    end

    it "should set the the password field of the packet to nil" do
      expect(packet.password).to be_nil
    end
  end

  describe "when parsing a simple 3.1.1 Connect packet" do
    let(:packet) do
      MQTT::Packet.parse(
        "\x10\x14\x00\x04MQTT\x04\x00\x00\x0a\x00\x08myclient"
      )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connect)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, false, false, false])
    end

    it "should set the Protocol Name of the packet correctly" do
      expect(packet.protocol_name).to eq('MQTT')
      expect(packet.protocol_name.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Protocol Level of the packet correctly" do
      expect(packet.protocol_level).to eq(4)
    end

    it "should set the Protocol version of the packet correctly" do
      expect(packet.version).to eq('3.1.1')
    end

    it "should set the Client Identifier of the packet correctly" do
      expect(packet.client_id).to eq('myclient')
      expect(packet.client_id.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Keep Alive timer of the packet correctly" do
      expect(packet.keep_alive).to eq(10)
    end

    it "should set not have the clean session flag set" do
      expect(packet.clean_session).to be_falsey
    end

    it "should set the the username field of the packet to nil" do
      expect(packet.username).to be_nil
    end

    it "should set the the password field of the packet to nil" do
      expect(packet.password).to be_nil
    end
  end

  describe "when parsing a Connect packet with the clean session flag set" do
    let(:packet) do
      MQTT::Packet.parse(
        "\x10\x16\x00\x06MQIsdp\x03\x02\x00\x0a\x00\x08myclient"
      )
    end

    it "should set the clean session flag" do
      expect(packet.clean_session).to be_truthy
    end
  end

  describe "when parsing a Connect packet with a Will and Testament" do
    let(:packet) do
      MQTT::Packet.parse(
        "\x10\x24\x00\x06MQIsdp\x03\x0e\x00\x0a\x00\x08myclient\x00\x05topic\x00\x05hello"
      )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connect)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, false, false, false])
    end

    it "should set the Protocol Name of the packet correctly" do
      expect(packet.protocol_name).to eq('MQIsdp')
      expect(packet.protocol_name.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Protocol Level of the packet correctly" do
      expect(packet.protocol_level).to eq(3)
    end

    it "should set the Protocol version of the packet correctly" do
      expect(packet.version).to eq('3.1.0')
    end

    it "should set the Client Identifier of the packet correctly" do
      expect(packet.client_id).to eq('myclient')
      expect(packet.client_id.encoding.to_s).to eq('UTF-8')
    end

    it "should set the clean session flag should be set" do
      expect(packet.clean_session).to be_truthy
    end

    it "should set the QoS of the Will should be 1" do
      expect(packet.will_qos).to eq(1)
    end

    it "should set the Will retain flag should be false" do
      expect(packet.will_retain).to be_falsey
    end

    it "should set the Will topic of the packet correctly" do
      expect(packet.will_topic).to eq('topic')
      expect(packet.will_topic.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Will payload of the packet correctly" do
      expect(packet.will_payload).to eq('hello')
      expect(packet.will_payload.encoding.to_s).to eq('UTF-8')
    end
  end

  describe "when parsing a Connect packet with a username and password" do
    let(:packet) do
      MQTT::Packet.parse(
        "\x10\x2A"+
        "\x00\x06MQIsdp"+
        "\x03\xC0\x00\x0a"+
        "\x00\x08myclient"+
        "\x00\x08username"+
        "\x00\x08password"
      )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connect)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, false, false, false])
    end

    it "should set the Protocol Name of the packet correctly" do
      expect(packet.protocol_name).to eq('MQIsdp')
      expect(packet.protocol_name.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Protocol Level of the packet correctly" do
      expect(packet.protocol_level).to eq(3)
    end

    it "should set the Protocol version of the packet correctly" do
      expect(packet.version).to eq('3.1.0')
    end

    it "should set the Client Identifier of the packet correctly" do
      expect(packet.client_id).to eq('myclient')
      expect(packet.client_id.encoding.to_s).to eq('UTF-8')
   end

    it "should set the Keep Alive Timer of the packet correctly" do
      expect(packet.keep_alive).to eq(10)
    end

    it "should set the Username of the packet correctly" do
      expect(packet.username).to eq('username')
      expect(packet.username.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Username of the packet correctly" do
      expect(packet.password).to eq('password')
      expect(packet.password.encoding.to_s).to eq('UTF-8')
    end
  end

  describe "when parsing a Connect that has a username but no password" do
    let(:packet) do
      MQTT::Packet.parse(
        "\x10\x20\x00\x06MQIsdp\x03\x80\x00\x0a\x00\x08myclient\x00\x08username"
      )
    end

    it "should set the Username of the packet correctly" do
      expect(packet.username).to eq('username')
      expect(packet.username.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Username of the packet correctly" do
      expect(packet.password).to be_nil
    end
  end

  describe "when parsing a Connect that has a password but no username" do
    let(:packet) do
      MQTT::Packet.parse(
        "\x10\x20\x00\x06MQIsdp\x03\x40\x00\x0a\x00\x08myclient\x00\x08password"
      )
    end

    it "should set the Username of the packet correctly" do
      expect(packet.username).to be_nil
    end

    it "should set the Username of the packet correctly" do
      expect(packet.password).to eq('password')
      expect(packet.password.encoding.to_s).to eq('UTF-8')
    end
  end

  describe "when parsing a Connect packet has the username and password flags set but doesn't have the fields" do
    let(:packet) do
      MQTT::Packet.parse(
        "\x10\x16\x00\x06MQIsdp\x03\xC0\x00\x0a\x00\x08myclient"
      )
    end

    it "should set the Username of the packet correctly" do
      expect(packet.username).to be_nil
    end

    it "should set the Username of the packet correctly" do
      expect(packet.password).to be_nil
    end
  end

  describe "when parsing a Connect packet with every option set" do
    let(:packet) do
      MQTT::Packet.parse(
        "\x10\x5F"+ # fixed header (2)
        "\x00\x06MQIsdp"+ # protocol name (8)
        "\x03\xf6"+ # protocol level + flags (2)
        "\xff\xff"+ # keep alive (2)
        "\x00\x1712345678901234567890123"+ # client identifier (25)
        "\x00\x0Awill_topic"+ # will topic (12)
        "\x00\x0Cwill_message"+ # will message (14)
        "\x00\x0Euser0123456789"+ # username (16)
        "\x00\x0Epass0123456789"  # password (16)
      )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connect)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, false, false, false])
    end

    it "should set the Protocol Name of the packet correctly" do
      expect(packet.protocol_name).to eq('MQIsdp')
      expect(packet.protocol_name.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Protocol Level of the packet correctly" do
      expect(packet.protocol_level).to eq(3)
    end

    it "should set the Protocol version of the packet correctly" do
      expect(packet.version).to eq('3.1.0')
    end

    it "should set the Keep Alive Timer of the packet correctly" do
      expect(packet.keep_alive).to eq(65535)
    end

    it "should set the Client Identifier of the packet correctly" do
      expect(packet.client_id).to eq('12345678901234567890123')
      expect(packet.client_id.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Will QoS of the packet correctly" do
      expect(packet.will_qos).to eq(2)
    end

    it "should set the Will retain flag of the packet correctly" do
      expect(packet.will_retain).to be_truthy
    end

    it "should set the Will topic of the packet correctly" do
      expect(packet.will_topic).to eq('will_topic')
      expect(packet.will_topic.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Will payload of the packet correctly" do
      expect(packet.will_payload).to eq('will_message')
      expect(packet.will_payload.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Username of the packet correctly" do
      expect(packet.username).to eq('user0123456789')
      expect(packet.username.encoding.to_s).to eq('UTF-8')
    end

    it "should set the Username of the packet correctly" do
      expect(packet.password).to eq('pass0123456789')
      expect(packet.password.encoding.to_s).to eq('UTF-8')
    end
  end

  describe "when parsing packet with an unknown protocol name" do
    it "should raise a protocol exception" do
      expect {
        packet = MQTT::Packet.parse(
          "\x10\x16\x00\x06FooBar\x03\x00\x00\x0a\x00\x08myclient"
        )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Unsupported protocol: FooBar/3"
      )
    end
  end

  describe "when parsing packet with an unknown protocol level" do
    it "should raise a protocol exception" do
      expect {
        packet = MQTT::Packet.parse(
          "\x10\x16\x00\x06MQIsdp\x02\x00\x00\x0a\x00\x08myclient"
        )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Unsupported protocol: MQIsdp/2"
      )
    end
  end

  describe "when parsing packet with invalid fixed header flags" do
    it "should raise a protocol exception" do
      expect {
        MQTT::Packet.parse(
          "\x13\x16\x00\x06MQIsdp\x03\x00\x00\x0a\x00\x08myclient"
        )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Invalid flags in CONNECT packet header"
      )
    end
  end

  describe "when calling the inspect method" do
    it "should output correct string for the default options" do
      packet = MQTT::Packet::Connect.new
      expect(packet.inspect).to eq("#<MQTT::Packet::Connect: keep_alive=15, clean, client_id=''>")
    end

    it "should output correct string when parameters are given" do
      packet = MQTT::Packet::Connect.new(
        :keep_alive => 10,
        :client_id => 'c123',
        :clean_session => false,
        :username => 'foo'
      )
      expect(packet.inspect).to eq("#<MQTT::Packet::Connect: keep_alive=10, client_id='c123', username='foo'>")
    end
  end

  describe "deprecated attributes" do
    it "should still have a protocol_version method that is that same as protocol_level" do
      packet = MQTT::Packet::Connect.new
      packet.protocol_version = 5
      expect(packet.protocol_version).to eq(5)
      expect(packet.protocol_level).to eq(5)
      packet.protocol_version = 4
      expect(packet.protocol_version).to eq(4)
      expect(packet.protocol_level).to eq(4)
    end
  end
end
