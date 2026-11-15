# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet'

describe MQTT::Packet::Pingresp do
  describe "when serialising a packet" do
    it "should output the correct bytes for a packet with no flags" do
      packet = MQTT::Packet::Pingresp.new
      expect(packet.to_s).to eq("\xD0\x00")
    end
  end

  describe "when parsing a packet" do
    it "should correctly create the right type of packet object" do
      packet = MQTT::Packet.parse( "\xD0\x00" )
      expect(packet.class).to eq(MQTT::Packet::Pingresp)
    end

    it "should raise an exception if the packet has a payload" do
      expect {
        MQTT::Packet.parse( "\xD0\x05hello" )
      }.to raise_error(
        'Extra bytes at end of Ping Response packet'
      )
    end
  end

  describe "when parsing packet with invalid fixed header flags" do
    it "should raise a protocol exception" do
      expect {
        MQTT::Packet.parse( "\xD2\x00" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Invalid flags in PINGRESP packet header"
      )
    end
  end

  it "should output the right string when calling inspect" do
    packet = MQTT::Packet::Pingresp.new
    expect(packet.inspect).to eq("#<MQTT::Packet::Pingresp>")
  end
end
