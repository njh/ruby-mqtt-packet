# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Willmsgreq do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Willmsgreq.new
    expect(packet.type_id).to eq(0x08)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes" do
      packet = MQTT::SN::Packet::Willmsgreq.new
      expect(packet.to_s).to eq("\x02\x08")
    end
  end

  describe "when parsing a Willmsgreq packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x02\x08") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Willmsgreq)
    end
  end
end

