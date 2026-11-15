# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Connack do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Connack.new
    expect(packet.type_id).to eq(0x05)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a sucessful connection acknowledgement packet" do
      packet = MQTT::SN::Packet::Connack.new(:return_code => 0x00)
      expect(packet.to_s).to eq("\x03\x05\x00")
    end

    it "should raise an exception if the return code isn't an Integer" do
      packet = MQTT::SN::Packet::Connack.new(:return_code => true)
      expect { packet.to_s }.to raise_error("return_code must be an Integer")
    end
  end

  describe "when parsing a successful Connection Accepted packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x03\x05\x00") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x00)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/accepted/i)
    end
  end

  describe "when parsing a congestion packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x03\x05\x01") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x01)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/rejected: congestion/i)
    end
  end

  describe "when parsing a invalid topic ID packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x03\x05\x02") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x02)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/rejected: invalid topic ID/i)
    end
  end

  describe "when parsing a 'not supported' packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x03\x05\x03") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x03)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/not supported/i)
    end
  end

  describe "when parsing an unknown connection refused packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x03\x05\x10") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Connack)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x10)
    end

    it "should set the return message of the packet correctly" do
      expect(packet.return_msg).to match(/rejected/i)
    end
  end
end
