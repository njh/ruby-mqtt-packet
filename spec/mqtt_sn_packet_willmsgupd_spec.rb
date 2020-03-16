# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Willmsgupd do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Willmsgupd.new
    expect(packet.type_id).to eq(0x1C)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a Willmsgupd packet" do
      packet = MQTT::SN::Packet::Willmsgupd.new(:data => 'test1')
      expect(packet.to_s).to eq("\x07\x1Ctest1")
    end
  end

  describe "when parsing a Willmsgupd packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x07\x1Ctest2") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Willmsgupd)
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.data).to eq('test2')
    end
  end
end
