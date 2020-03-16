# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Willmsg do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Willmsg.new
    expect(packet.type_id).to eq(0x09)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a Willmsg packet" do
      packet = MQTT::SN::Packet::Willmsg.new(:data => 'msg')
      expect(packet.to_s).to eq("\x05\x09msg")
    end
  end

  describe "when parsing a Willmsg packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x0D\x09willmessage") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Willmsg)
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.data).to eq('willmessage')
    end
  end
end
