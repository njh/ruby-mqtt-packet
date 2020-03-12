# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet'

describe MQTT::Packet::Connack do
  describe "when setting attributes on a packet" do
    let(:packet) {  MQTT::Packet::Connack.new }

    it "should let you change the session present flag of a packet" do
      packet.session_present = true
      expect(packet.session_present).to be_truthy
    end

    it "should let you change the session present flag of a packet using an integer" do
      packet.session_present = 1
      expect(packet.session_present).to be_truthy
    end

    it "should let you change the return code of a packet" do
      packet.return_code = 3
      expect(packet.return_code).to eq(3)
    end
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a sucessful connection acknowledgement packet without Session Present set" do
      packet = MQTT::Packet::Connack.new( :return_code => 0x00, :session_present => false )
      expect(packet.to_s).to eq("\x20\x02\x00\x00")
    end

    it "should output the correct bytes for a sucessful connection acknowledgement packet with Session Present set" do
      packet = MQTT::Packet::Connack.new( :return_code => 0x00, :session_present => true )
      expect(packet.to_s).to eq("\x20\x02\x01\x00")
    end
  end

  describe "when parsing a successful Connection Accepted packet" do
    let(:packet) do
      MQTT::Packet.parse( "\x20\x02\x00\x00" )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connack)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, false, false, false])
    end

    it "should set the Session Pression flag of the packet correctly" do
      expect(packet.session_present).to eq(false)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x00)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/Connection Accepted/i)
    end
  end

  describe "when parsing a successful Connection Accepted packet with Session Present set" do
    let(:packet) do
      MQTT::Packet.parse( "\x20\x02\x01\x00" )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connack)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, false, false, false])
    end

    it "should set the Session Pression flag of the packet correctly" do
      expect(packet.session_present).to eq(true)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x00)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/Connection Accepted/i)
    end
  end

  describe "when parsing a unacceptable protocol version packet" do
    let(:packet) do
      MQTT::Packet.parse( "\x20\x02\x00\x01" )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x01)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/unacceptable protocol version/i)
    end
  end

  describe "when parsing a client identifier rejected packet" do
    let(:packet) { MQTT::Packet.parse( "\x20\x02\x00\x02" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x02)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/client identifier rejected/i)
    end
  end

  describe "when parsing a server unavailable packet" do
    let(:packet) do
      MQTT::Packet.parse( "\x20\x02\x00\x03" )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x03)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/server unavailable/i)
    end
  end

  describe "when parsing a server unavailable packet" do
    let(:packet) do
      MQTT::Packet.parse( "\x20\x02\x00\x04" )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x04)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/bad user name or password/i)
    end
  end

  describe "when parsing a server unavailable packet" do
    let(:packet) do
      MQTT::Packet.parse( "\x20\x02\x00\x05" )
    end

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x05)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/not authorised/i)
    end
  end

  describe "when parsing an unknown connection refused packet" do
    let(:packet) { MQTT::Packet.parse( "\x20\x02\x00\x10" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x10)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/Connection refused: error code 16/i)
    end
  end

  describe "when parsing packet with invalid Connack flags set" do
    it "should raise an exception" do
      expect {
        packet = MQTT::Packet.parse( "\x20\x02\xff\x05" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Invalid flags in Connack variable header"
      )
    end
  end

  describe "when parsing packet with extra bytes on the end" do
    it "should raise an exception" do
      expect {
        packet = MQTT::Packet.parse( "\x20\x03\x00\x00\x00" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Extra bytes at end of Connect Acknowledgment packet"
      )
    end
  end

  describe "when parsing packet with invalid fixed header flags" do
    it "should raise a protocol exception" do
      expect {
        MQTT::Packet.parse( "\x23\x02\x00\x00" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Invalid flags in CONNACK packet header"
      )
    end
  end

  describe "when calling the inspect method" do
    it "should output the right string when the return code is 0" do
      packet = MQTT::Packet::Connack.new( :return_code => 0x00 )
      expect(packet.inspect).to eq("#<MQTT::Packet::Connack: 0x00>")
    end
    it "should output the right string when the return code is 0x0F" do
      packet = MQTT::Packet::Connack.new( :return_code => 0x0F )
      expect(packet.inspect).to eq("#<MQTT::Packet::Connack: 0x0F>")
    end
  end
end

