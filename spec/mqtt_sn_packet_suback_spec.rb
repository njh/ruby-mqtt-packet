# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Suback do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Suback.new
    expect(packet.type_id).to eq(0x13)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a normal topic id" do
      packet = MQTT::SN::Packet::Suback.new(
        :id => 0x02,
        :qos => 0,
        :topic_id => 0x01,
        :return_code => 0x03
      )
      expect(packet.to_s).to eq("\x08\x13\x00\x00\x01\x00\x02\x03")
    end

    it "should output the correct bytes for a short topic id" do
      packet = MQTT::SN::Packet::Suback.new(
        :id => 0x03,
        :qos => 0,
        :topic_id => 'tt',
        :topic_id_type => :short,
        :return_code => 0x03
      )
      expect(packet.to_s).to eq("\x08\x13\x02tt\x00\x03\x03")
    end

    it "should output the correct bytes for a packet with no topic id" do
      packet = MQTT::SN::Packet::Suback.new(
        :id => 0x02,
        :return_code => 0x02
      )
      expect(packet.to_s).to eq("\x08\x13\x00\x00\x00\x00\x02\x02")
    end

    it "should raise an exception if the Packet Id isn't an Integer" do
      packet = MQTT::SN::Packet::Suback.new(:id => "0x45")
      expect { packet.to_s }.to raise_error("id must be an Integer")
    end

    it "should raise an exception if the Topic Id isn't an Integer" do
      packet = MQTT::SN::Packet::Suback.new(:topic_id => "0x45", :topic_id_type => :normal)
      expect { packet.to_s }.to raise_error("topic_id must be an Integer for type normal")
    end

    it "should raise an exception if the Topic Id isn't a String" do
      packet = MQTT::SN::Packet::Suback.new(:topic_id => 10, :topic_id_type => :short)
      expect { packet.to_s }.to raise_error("topic_id must be an String for type short")
    end
  end

  describe "when parsing a SUBACK packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x08\x13\x00\x00\x01\x00\x02\x03") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Suback)
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.qos).to eq(0)
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to eq(:normal)
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to eq(0x01)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x02)
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.return_code).to eq(0x03)
    end
  end
end
