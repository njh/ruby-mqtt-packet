# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Register do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Register.new
    expect(packet.type_id).to eq(0x0A)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes" do
      packet = MQTT::SN::Packet::Register.new(
        :id => 0x01,
        :topic_id => 0x01,
        :topic_name => 'test'
      )
      expect(packet.to_s).to eq("\x0A\x0A\x00\x01\x00\x01test")
    end

    it "should raise an exception if the Packet Id isn't an Integer" do
      packet = MQTT::SN::Packet::Register.new(:id => "0x45")
      expect { packet.to_s }.to raise_error("id must be an Integer")
    end

    it "should raise an exception if the Topic Id isn't an Integer" do
      packet = MQTT::SN::Packet::Register.new(:topic_id => "0x45")
      expect { packet.to_s }.to raise_error("topic_id must be an Integer")
    end
  end

  describe "when parsing a Register packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x0A\x0A\x00\x01\x00\x01test") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Register)
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to eq(:normal)
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to eq(0x01)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x01)
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.topic_name).to eq('test')
    end
  end
end

