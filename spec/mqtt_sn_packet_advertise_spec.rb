# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Advertise do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Advertise.new
    expect(packet.type_id).to eq(0x00)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes" do
      packet = MQTT::SN::Packet::Advertise.new(:gateway_id => 5, :duration => 30)
      expect(packet.to_s).to eq("\x05\x00\x05\x00\x1E")
    end
  end

  describe "when parsing a ADVERTISE packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x05\x00\x05\x00\x3C") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Advertise)
    end

    it "should set the gateway id of the packet correctly" do
      expect(packet.gateway_id).to eq(5)
    end

    it "should set the duration of the packet correctly" do
      expect(packet.duration).to eq(60)
    end
  end
end
