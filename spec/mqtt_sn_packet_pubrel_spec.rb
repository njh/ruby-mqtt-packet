# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Pubrel do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Pubrel.new
    expect(packet.type_id).to eq(0x10)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes" do
      packet = MQTT::SN::Packet::Pubrel.new(:id => 0x02)
      expect(packet.to_s).to eq("\x04\x10\x00\x02")
    end

    it "should raise an exception if the Packet Id isn't an Integer" do
      packet = MQTT::SN::Packet::Pubrel.new(:id => "0x45")
      expect { packet.to_s }.to raise_error("id must be an Integer")
    end
  end

  describe "when parsing a PUBREL packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x04\x10\x00\x02") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Pubrel)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x02)
    end
  end
end

