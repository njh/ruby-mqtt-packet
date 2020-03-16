# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Willmsgresp do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Willmsgresp.new
    expect(packet.type_id).to eq(0x1D)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes" do
      packet = MQTT::SN::Packet::Willmsgresp.new(
        :return_code => 0x03
      )
      expect(packet.to_s).to eq("\x03\x1D\x03")
    end

    it "should raise an exception if the return code isn't an Integer" do
      packet = MQTT::SN::Packet::Willmsgresp.new(:return_code => true)
      expect { packet.to_s }.to raise_error("return_code must be an Integer")
    end
  end

  describe "when parsing a WILLMSGRESP packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x03\x1D\x04") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Willmsgresp)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x04)
    end
  end
end
