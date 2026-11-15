# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Subscribe do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Subscribe.new
    expect(packet.type_id).to eq(0x12)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a Subscribe packet with a normal topic name" do
      packet = MQTT::SN::Packet::Subscribe.new(
        :duplicate => false,
        :qos => 0,
        :id => 0x02,
        :topic_name => 'test'
      )
      expect(packet.to_s).to eq("\x09\x12\x00\x00\x02test")
    end

    it "should output the correct bytes for a Subscribe packet with a short topic name" do
      packet = MQTT::SN::Packet::Subscribe.new(
        :duplicate => false,
        :qos => 0,
        :id => 0x04,
        :topic_id_type => :short,
        :topic_name => 'TT'
      )
      expect(packet.to_s).to eq("\x07\x12\x02\x00\x04TT")
    end

    it "should output the correct bytes for a Subscribe packet with a short topic id" do
      packet = MQTT::SN::Packet::Subscribe.new(
        :duplicate => false,
        :qos => 0,
        :id => 0x04,
        :topic_id_type => :short,
        :topic_id => 'TT'
      )
      expect(packet.to_s).to eq("\x07\x12\x02\x00\x04TT")
    end

    it "should output the correct bytes for a Subscribe packet with a predefined topic id" do
      packet = MQTT::SN::Packet::Subscribe.new(
        :duplicate => false,
        :qos => 0,
        :id => 0x05,
        :topic_id_type => :predefined,
        :topic_id => 16
      )
      expect(packet.to_s).to eq("\x07\x12\x01\x00\x05\x00\x10")
    end

    it "should raise an exception if the Packet Id isn't an Integer" do
      packet = MQTT::SN::Packet::Subscribe.new(:id => "0x45")
      expect { packet.to_s }.to raise_error("id must be an Integer")
    end
  end

  describe "when parsing a Subscribe packet with a normal topic id type" do
    let(:packet) { MQTT::SN::Packet.parse("\x09\x12\x00\x00\x03test") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Subscribe)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x03)
    end

    it "should set the QoS value of the packet correctly" do
      expect(packet.qos).to eq(0)
    end

    it "should set the duplicate flag of the packet correctly" do
      expect(packet.duplicate).to eq(false)
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to eq(:normal)
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.topic_name).to eq('test')
    end
  end

  describe "when parsing a Subscribe packet with a short topic id type" do
    let(:packet) { MQTT::SN::Packet.parse("\x07\x12\x02\x00\x04TT") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Subscribe)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x04)
    end

    it "should set the QoS value of the packet correctly" do
      expect(packet.qos).to eq(0)
    end

    it "should set the duplicate flag of the packet correctly" do
      expect(packet.duplicate).to eq(false)
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to eq(:short)
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to eq('TT')
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.topic_name).to eq('TT')
    end
  end

  describe "when parsing a Subscribe packet with a predefined topic id type" do
    let(:packet) { MQTT::SN::Packet.parse("\x07\x12\x01\x00\x05\x00\x10") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Subscribe)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x05)
    end

    it "should set the QoS value of the packet correctly" do
      expect(packet.qos).to eq(0)
    end

    it "should set the duplicate flag of the packet correctly" do
      expect(packet.duplicate).to eq(false)
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to eq(:predefined)
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to eq(16)
    end

    it "should set the topic name of the packet to nil" do
      expect(packet.topic_name).to be_nil
    end
  end
end
