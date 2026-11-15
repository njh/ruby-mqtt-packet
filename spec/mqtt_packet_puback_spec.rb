# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet'

describe MQTT::Packet::Puback do
  describe "when serialising a packet" do
    it "should output the correct bytes for a packet with no flags" do
      packet = MQTT::Packet::Puback.new( :id => 0x1234 )
      expect(packet.to_s).to eq("\x40\x02\x12\x34")
    end
  end

  describe "when parsing a packet" do
    let(:packet) { MQTT::Packet.parse( "\x40\x02\x12\x34" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Puback)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x1234)
    end
  end

  describe "when parsing packet with extra bytes on the end" do
    it "should raise an exception" do
      expect {
        packet = MQTT::Packet.parse( "\x40\x03\x12\x34\x00" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Extra bytes at end of Publish Acknowledgment packet"
      )
    end
  end

  describe "when parsing packet with invalid fixed header flags" do
    it "should raise a protocol exception" do
      expect {
        MQTT::Packet.parse( "\x43\x02\x12\x34" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Invalid flags in PUBACK packet header"
      )
    end
  end

  it "should output the right string when calling inspect" do
    packet = MQTT::Packet::Puback.new( :id => 0x1234 )
    expect(packet.inspect).to eq("#<MQTT::Packet::Puback: 0x1234>")
  end
end
