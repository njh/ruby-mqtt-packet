# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Puback do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Puback.new
    expect(packet.type_id).to eq(0x0D)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes" do
      packet = MQTT::SN::Packet::Puback.new(:id => 0x02, :topic_id => 0x03, :return_code => 0x01)
      expect(packet.to_s).to eq("\x07\x0D\x00\x03\x00\x02\x01")
    end

    it "should raise an exception if the Packet Id isn't an Integer" do
      packet = MQTT::SN::Packet::Puback.new(:id => "0x45")
      expect { packet.to_s }.to raise_error("id must be an Integer")
    end

    it "should raise an exception if the Topic Id isn't an Integer" do
      packet = MQTT::SN::Packet::Puback.new(:topic_id => "0x45")
      expect { packet.to_s }.to raise_error("topic_id must be an Integer")
    end
  end

  describe "when parsing a PUBACK packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x07\x0D\x00\x01\x00\x02\x03") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Puback)
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to eq(0x01)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x02)
    end

    it "should set the return code of the packet correctly" do
      expect(packet.return_code).to eq(0x03)
    end
  end
end
