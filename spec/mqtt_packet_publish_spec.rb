# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet'

describe MQTT::Packet::Publish do
  describe "when creating a packet" do
    it "should allow you to set the packet QoS level as a hash parameter" do
      packet = MQTT::Packet::Publish.new( :qos => 2 )
      expect(packet.qos).to eq(2)
    end

    it "should allow you to set the packet retain flag as a hash parameter" do
      packet = MQTT::Packet::Publish.new( :retain => true )
      expect(packet.retain).to be_truthy
    end

    it "should raise an exception the QoS is greater than 2" do
      expect {
        packet = MQTT::Packet::Publish.new( :qos => 3 )
      }.to raise_error(
        'Invalid QoS value: 3'
      )
    end

    it "should raise an exception the QoS is less than 0" do
      expect {
        packet = MQTT::Packet::Publish.new( :qos => -1 )
      }.to raise_error(
        'Invalid QoS value: -1'
      )
    end
  end

  describe "when setting attributes on a packet" do
    let(:packet) {
      MQTT::Packet::Publish.new(
        :duplicate => false,
        :qos => 0,
        :retain => false
      )
    }

    it "should let you change the dup flag of a packet" do
      packet.duplicate = true
      expect(packet.duplicate).to be_truthy
    end

    it "should let you change the dup flag of a packet using an integer" do
      packet.duplicate = 1
      expect(packet.duplicate).to be_truthy
    end

    it "should let you change the QoS value of a packet" do
      packet.qos = 1
      expect(packet.qos).to eq(1)
    end

    it "should let you change the retain flag of a packet" do
      packet.retain = true
      expect(packet.retain).to be_truthy
    end

    it "should let you change the retain flag of a packet using an integer" do
      packet.retain = 1
      expect(packet.retain).to be_truthy
    end
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a packet with default QoS and no flags" do
      packet = MQTT::Packet::Publish.new( :topic => 'test', :payload => 'hello world' )
      expect(packet.to_s).to eq("\x30\x11\x00\x04testhello world")
    end

    it "should output the correct bytes for a packet with QoS 1 and no flags" do
      packet = MQTT::Packet::Publish.new( :id => 5, :qos => 1, :topic => 'a/b', :payload => 'hello world' )
      expect(packet.to_s).to eq("\x32\x12\x00\x03a/b\x00\x05hello world")
    end

    it "should output the correct bytes for a packet with QoS 2 and retain flag set" do
      packet = MQTT::Packet::Publish.new( :id => 5, :qos => 2, :retain => true, :topic => 'c/d', :payload => 'hello world' )
      expect(packet.to_s).to eq("\x35\x12\x00\x03c/d\x00\x05hello world")
    end

    it "should output the correct bytes for a packet with QoS 2 and dup flag set" do
      packet = MQTT::Packet::Publish.new( :id => 5, :qos => 2, :duplicate => true, :topic => 'c/d', :payload => 'hello world' )
      expect(packet.to_s).to eq("\x3C\x12\x00\x03c/d\x00\x05hello world")
    end

    it "should output the correct bytes for a packet with an empty payload" do
      packet = MQTT::Packet::Publish.new( :topic => 'test' )
      expect(packet.to_s).to eq("\x30\x06\x00\x04test")
    end

    it "should output a string as binary / 8-bit ASCII" do
      packet = MQTT::Packet::Publish.new( :topic => 'test', :payload => 'hello world' )
      expect(packet.to_s.encoding.to_s).to eq("ASCII-8BIT")
    end

    it "should support passing in non-strings to the topic and payload" do
      packet = MQTT::Packet::Publish.new( :topic => :symbol, :payload => 1234 )
      expect(packet.to_s).to eq("\x30\x0c\x00\x06symbol1234")
    end

    it "should raise an exception when there is no topic name" do
      expect {
        MQTT::Packet::Publish.new.to_s
      }.to raise_error(
        'Invalid topic name when serialising packet'
      )
    end

    it "should raise an exception when there is an empty topic name" do
      expect {
        MQTT::Packet::Publish.new( :topic => '' ).to_s
      }.to raise_error(
        'Invalid topic name when serialising packet'
      )
    end
  end

  describe "when serialising an oversized packet" do
    it "should raise an exception when body is bigger than 256MB" do
      expect {
        packet = MQTT::Packet::Publish.new( :topic => 'test', :payload => 'x'*268435455 )
        packet.to_s
      }.to raise_error(
        'Error serialising packet: body is more than 256MB'
      )
    end
  end

  describe "when parsing a packet with QoS 0" do
    let(:packet) { MQTT::Packet.parse( "\x30\x11\x00\x04testhello world" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Publish)
    end

    it "should set the QoS level correctly" do
      expect(packet.qos).to eq(0)
    end

    it "should set the RETAIN flag correctly" do
      expect(packet.retain).to be_falsey
    end

    it "should set the DUP flag correctly" do
      expect(packet.duplicate).to be_falsey
    end

    it "should set the topic name correctly" do
      expect(packet.topic).to eq('test')
      expect(packet.topic.encoding.to_s).to eq('UTF-8')
    end

    it "should set the payload correctly" do
      expect(packet.payload).to eq('hello world')
      expect(packet.payload.encoding.to_s).to eq('ASCII-8BIT')
    end
  end

  describe "when parsing a packet with QoS 2 and retain and dup flags set" do
    let(:packet) { MQTT::Packet.parse( "\x3D\x12\x00\x03c/d\x00\x05hello world" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Publish)
    end

    it "should set the QoS level correctly" do
      expect(packet.qos).to eq(2)
    end

    it "should set the RETAIN flag correctly" do
      expect(packet.retain).to be_truthy
    end

    it "should set the DUP flag correctly" do
      expect(packet.duplicate).to be_truthy
    end

    it "should set the topic name correctly" do
      expect(packet.topic).to eq('c/d')
      expect(packet.topic.encoding.to_s).to eq('UTF-8')
    end

    it "should set the payload correctly" do
      expect(packet.payload).to eq('hello world')
      expect(packet.payload.encoding.to_s).to eq('ASCII-8BIT')
    end
  end

  describe "when parsing a packet with an empty payload" do
    let(:packet) { MQTT::Packet.parse( "\x30\x06\x00\x04test" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Publish)
    end

    it "should set the topic name correctly" do
      expect(packet.topic).to eq('test')
    end

    it "should set the payload correctly" do
      expect(packet.payload).to be_empty
    end
  end

  describe "when parsing a packet with a QoS value of 3" do
    it "should raise an exception" do
      expect {
        packet = MQTT::Packet.parse( "\x36\x12\x00\x03a/b\x00\x05hello world" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        'Invalid packet: QoS value of 3 is not allowed'
      )
    end
  end

  describe "when parsing a packet with QoS value of 0 and DUP set" do
    it "should raise an exception" do
      expect {
        packet = MQTT::Packet.parse( "\x38\x10\x00\x03a/bhello world" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        'Invalid packet: DUP cannot be set for QoS 0'
      )
    end
  end

  describe "when parsing a packet with a body of 314 bytes" do
    let(:packet) {
      # 0x30 = publish
      # 0xC1 = (65 * 1)
      # 0x02 = (2 * 128)
      MQTT::Packet.parse( "\x30\xC1\x02\x00\x05topic" + ('x' * 314) )
    }

    it "should parse the packet type correctly" do
      expect(packet.class).to eq(MQTT::Packet::Publish)
    end

    it "should get the topic name correctly" do
      expect(packet.topic).to eq('topic')
    end

    it "should get the body length correctly" do
      expect(packet.payload.bytesize).to eq(314)
    end
  end

  describe "when parsing a packet with a body of 16kbytes" do
    let(:packet) do
      # 0x30 = publish
      # 0x87 = (7 * 1)
      # 0x80 = (0 * 128)
      # 0x01 = (1 * 16384)
      MQTT::Packet.parse( "\x30\x87\x80\x01\x00\x05topic" + ('x'*16384) )
    end

    it "should parse the packet type correctly" do
      expect(packet.class).to eq(MQTT::Packet::Publish)
    end

    it "should get the topic name correctly" do
      expect(packet.topic).to eq('topic')
    end

    it "should get the body length correctly" do
      expect(packet.payload.bytesize).to eq(16384)
    end
  end

  describe "processing a packet containing UTF-8 character" do
    let(:packet) do
      MQTT::Packet::Publish.new(
        :topic => "Test ①".force_encoding("UTF-8"),
        :payload => "Snowman: ☃".force_encoding("UTF-8")
      )
    end

    it "should have the correct topic byte length" do
      expect(packet.topic.bytesize).to eq(8)
    end

    it "should have the correct topic string length", :unless => RUBY_VERSION =~ /^1\.8/ do
      # Ruby 1.8 doesn't support UTF-8 properly
      expect(packet.topic.length).to eq(6)
    end

    it "should have the correct payload byte length" do
      expect(packet.payload.bytesize).to eq(12)
    end

    it "should have the correct payload string length", :unless => RUBY_VERSION =~ /^1\.8/ do
      # Ruby 1.8 doesn't support UTF-8 properly
      expect(packet.payload.length).to eq(10)
    end

    it "should encode to MQTT packet correctly" do
      expect(packet.to_s).to eq("\x30\x16\x00\x08Test \xE2\x91\xA0Snowman: \xE2\x98\x83".force_encoding('BINARY'))
    end

    it "should parse the serialised packet" do
      packet2 = MQTT::Packet.parse( packet.to_s )
      expect(packet2.topic).to eq("Test ①".force_encoding('UTF-8'))
      expect(packet2.payload).to eq("Snowman: ☃".force_encoding('BINARY'))
    end
  end

  describe "reading a packet from a socket" do
    let(:socket) { StringIO.new("\x30\x11\x00\x04testhello world") }
    let(:packet) { MQTT::Packet.read(socket) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Publish)
    end

    it "should set the body length is read correctly" do
      expect(packet.body_length).to eq(17)
    end

    it "should set the QoS level correctly" do
      expect(packet.qos).to eq(0)
    end

    it "should set the RETAIN flag correctly" do
      expect(packet.retain).to be_falsey
    end

    it "should set the DUP flag correctly" do
      expect(packet.duplicate).to be_falsey
    end

    it "should set the topic name correctly" do
      expect(packet.topic).to eq('test')
      expect(packet.topic.encoding.to_s).to eq('UTF-8')
    end

    it "should set the payload correctly" do
      expect(packet.payload).to eq('hello world')
      expect(packet.payload.encoding.to_s).to eq('ASCII-8BIT')
    end
  end

  describe "when calling the inspect method" do
    it "should output the payload, if it is less than 16 bytes" do
      packet = MQTT::Packet::Publish.new( :topic => "topic", :payload => "payload" )
      expect(packet.inspect).to eq("#<MQTT::Packet::Publish: d0, q0, r0, m0, 'topic', 'payload'>")
    end

    it "should output the length of the payload, if it is more than 16 bytes" do
      packet = MQTT::Packet::Publish.new( :topic => "topic", :payload => 'x'*32 )
      expect(packet.inspect).to eq("#<MQTT::Packet::Publish: d0, q0, r0, m0, 'topic', ... (32 bytes)>")
    end

    it "should only output the length of a binary payload" do
      packet = MQTT::Packet.parse("\x31\x12\x00\x04test\x8D\xF8\x09\x40\xC4\xE7\x4f\xF0\xFF\x30\xE0\xE7")
      expect(packet.inspect).to eq("#<MQTT::Packet::Publish: d0, q0, r1, m0, 'test', ... (12 bytes)>")
    end
  end
end
