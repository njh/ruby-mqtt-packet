# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Pingresp do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Pingresp.new
    expect(packet.type_id).to eq(0x17)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a pingresp packet" do
      packet = MQTT::SN::Packet::Pingresp.new
      expect(packet.to_s).to eq("\x02\x17")
    end
  end

  describe "when parsing a Pingresp packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x02\x17") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Pingresp)
    end
  end
end
