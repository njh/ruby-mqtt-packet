# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Searchgw do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Searchgw.new
    expect(packet.type_id).to eq(0x01)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes" do
      packet = MQTT::SN::Packet::Searchgw.new(:radius => 2)
      expect(packet.to_s).to eq("\x03\x01\x02")
    end
  end

  describe "when parsing a ADVERTISE packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x03\x01\x03") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Searchgw)
    end

    it "should set the duration of the packet correctly" do
      expect(packet.radius).to eq(3)
    end
  end
end
