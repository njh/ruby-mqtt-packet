# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Gwinfo do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Gwinfo.new
    expect(packet.type_id).to eq(0x02)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes when there is no gateway address" do
      packet = MQTT::SN::Packet::Gwinfo.new(:gateway_id => 6)
      expect(packet.to_s).to eq("\x03\x02\x06")
    end

    it "should output the correct bytes with a gateway address" do
      packet = MQTT::SN::Packet::Gwinfo.new(:gateway_id => 6, :gateway_address => 'ADDR')
      expect(packet.to_s).to eq("\x07\x02\x06ADDR")
    end
  end

  describe "when parsing a GWINFO packet with no gateway address" do
    let(:packet) { MQTT::SN::Packet.parse("\x03\x02\x06") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Gwinfo)
    end

    it "should set the Gateway ID of the packet correctly" do
      expect(packet.gateway_id).to eq(6)
    end

    it "should set the Gateway ID of the packet correctly" do
      expect(packet.gateway_address).to be_nil
    end
  end

  describe "when parsing a GWINFO packet with a gateway address" do
    let(:packet) { MQTT::SN::Packet.parse("\x07\x02\x06ADDR") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Gwinfo)
    end

    it "should set the Gateway ID of the packet correctly" do
      expect(packet.gateway_id).to eq(6)
    end

    it "should set the Gateway ID of the packet correctly" do
      expect(packet.gateway_address).to eq('ADDR')
    end
  end
end

