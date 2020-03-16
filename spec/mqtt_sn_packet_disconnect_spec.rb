# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Disconnect do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Disconnect.new
    expect(packet.type_id).to eq(0x18)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a disconnect packet" do
      packet = MQTT::SN::Packet::Disconnect.new
      expect(packet.to_s).to eq("\x02\x18")
    end

    it "should output the correct bytes for a disconnect packet with a duration" do
      packet = MQTT::SN::Packet::Disconnect.new(:duration => 10)
      expect(packet.to_s).to eq("\x04\x18\x00\x0A")
    end
  end

  describe "when parsing a Disconnect packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x02\x18") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Disconnect)
    end

    it "should have the duration field set to nil" do
      expect(packet.duration).to be_nil
    end
  end

  describe "when parsing a Disconnect packet with duration field" do
    let(:packet) { MQTT::SN::Packet.parse("\x04\x18\x00\x0A") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Disconnect)
    end

    it "should have the duration field set to 10" do
      expect(packet.duration).to eq(10)
    end
  end
end
