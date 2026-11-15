# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Willtopicupd do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Willtopicupd.new
    expect(packet.type_id).to eq(0x1A)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a Willtopicupd packet" do
      packet = MQTT::SN::Packet::Willtopicupd.new(:topic_name => 'test', :qos => 0)
      expect(packet.to_s).to eq("\x07\x1A\x00test")
    end

    it "should output the correct bytes for a Willtopic packet with QoS 1" do
      packet = MQTT::SN::Packet::Willtopicupd.new(:topic_name => 'test', :qos => 1)
      expect(packet.to_s).to eq("\x07\x1A\x20test")
    end

    it "should output the correct bytes for a Willtopic packet with no topic name" do
      packet = MQTT::SN::Packet::Willtopicupd.new(:topic_name => nil)
      expect(packet.to_s).to eq("\x02\x1A")
    end

    it "should output the correct bytes for a Willtopic packet with an empty topic name" do
      packet = MQTT::SN::Packet::Willtopicupd.new(:topic_name => '')
      expect(packet.to_s).to eq("\x02\x1A")
    end
  end

  describe "when parsing a Willtopicupd packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x07\x1A\x40test") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Willtopicupd)
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.topic_name).to eq('test')
    end

    it "should set the QoS value of the packet correctly" do
      expect(packet.qos).to eq(2)
    end

    it "should set the retain flag of the packet correctly" do
      expect(packet.retain).to be_falsy
    end
  end

  describe "when parsing a Willtopicupd packet with no topic name" do
    let(:packet) { MQTT::SN::Packet.parse("\x02\x1A") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Willtopicupd)
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.topic_name).to be_nil
    end
  end
end
