# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Publish do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Publish.new
    expect(packet.type_id).to eq(0x0C)
  end

  describe "when serialising a packet with a normal topic id type" do
    it "should output the correct bytes for a publish packet" do
      packet = MQTT::SN::Packet::Publish.new(
        :topic_id => 0x01,
        :topic_id_type => :normal,
        :data => "Hello World"
      )
      expect(packet.to_s).to eq("\x12\x0C\x00\x00\x01\x00\x00Hello World")
    end

    it "should raise an exception if the Packet Id isn't an Integer" do
      packet = MQTT::SN::Packet::Publish.new(:id => "0x45")
      expect { packet.to_s }.to raise_error("id must be an Integer")
    end
  end

  describe "when serialising a packet with a short topic id type" do
    it "should output the correct bytes for a publish packet of QoS -1" do
      packet = MQTT::SN::Packet::Publish.new(
        :qos => -1,
        :topic_id => 'tt',
        :topic_id_type => :short,
        :data => "Hello World"
      )
      expect(packet.to_s).to eq("\x12\x0C\x62tt\x00\x00Hello World")
    end

    it "should output the correct bytes for a publish packet of QoS 0" do
      packet = MQTT::SN::Packet::Publish.new(
        :qos => 0,
        :topic_id => 'tt',
        :topic_id_type => :short,
        :data => "Hello World"
      )
      expect(packet.to_s).to eq("\x12\x0C\x02tt\x00\x00Hello World")
    end

    it "should output the correct bytes for a publish packet of QoS 1" do
      packet = MQTT::SN::Packet::Publish.new(
        :qos => 1,
        :topic_id => 'tt',
        :topic_id_type => :short,
        :data => "Hello World"
      )
      expect(packet.to_s).to eq("\x12\x0C\x22tt\x00\x00Hello World")
    end

    it "should output the correct bytes for a publish packet of QoS 2" do
      packet = MQTT::SN::Packet::Publish.new(
        :qos => 2,
        :topic_id => 'tt',
        :topic_id_type => :short,
        :data => "Hello World"
      )
      expect(packet.to_s).to eq("\x12\x0C\x42tt\x00\x00Hello World")
    end
  end

  describe "when serialising a packet with a pre-defined topic id type" do
    it "should output the correct bytes for a publish packet" do
      packet = MQTT::SN::Packet::Publish.new(
        :topic_id => 0x00EE,
        :topic_id_type => :predefined,
        :data => "Hello World"
      )
      expect(packet.to_s).to eq("\x12\x0C\x01\x00\xEE\x00\x00Hello World")
    end
  end

  describe "when serialising packet larger than 256 bytes" do
    let(:packet) {
      MQTT::SN::Packet::Publish.new(
        :topic_id => 0x10,
        :topic_id_type => :normal,
        :data => "Hello World" * 100
      )
    }

    it "should have the first three bytes set to 0x01, 0x04, 0x55" do
      expect(packet.to_s.unpack('CCC')).to eq([0x01,0x04,0x55])
    end

    it "should have a total length of 0x0455 (1109) bytes" do
      expect(packet.to_s.length).to eq(0x0455)
    end
  end

  describe "when serialising an excessively large packet" do
    it "should raise an exception" do
      expect {
        MQTT::SN::Packet::Publish.new(
          :topic_id => 0x01,
          :topic_id_type => :normal,
          :data => "Hello World" * 6553
        ).to_s
      }.to raise_error(
        RuntimeError,
        "MQTT-SN Packet is too big, maximum packet body size is 65531"
      )
    end
  end

  describe "when parsing a Publish packet with a normal topic id" do
    let(:packet) { MQTT::SN::Packet.parse("\x12\x0C\x00\x00\x01\x00\x00Hello World") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Publish)
    end

    it "should set the QoS value of the packet correctly" do
      expect(packet.qos).to be === 0
    end

    it "should set the duplicate flag of the packet correctly" do
      expect(packet.duplicate).to be === false
    end

    it "should set the retain flag of the packet correctly" do
      expect(packet.retain).to be === false
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id_type).to be === :normal
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to be === 0x01
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to be === 0x0000
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.data).to eq("Hello World")
    end
  end

  describe "when parsing a Publish packet with a short topic id" do
    let(:packet) { MQTT::SN::Packet.parse("\x12\x0C\x02tt\x00\x00Hello World") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Publish)
    end

    it "should set the QoS value of the packet correctly" do
      expect(packet.qos).to be === 0
    end

    it "should set the duplicate flag of the packet correctly" do
      expect(packet.duplicate).to be === false
    end

    it "should set the retain flag of the packet correctly" do
      expect(packet.retain).to be === false
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to be === :short
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to be === 'tt'
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to be === 0x0000
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.data).to eq("Hello World")
    end
  end

  describe "when parsing a Publish packet with a short topic id and QoS -1" do
    let(:packet) { MQTT::SN::Packet.parse("\x12\x0C\x62tt\x00\x00Hello World") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Publish)
    end

    it "should set the QoS value of the packet correctly" do
      expect(packet.qos).to be === -1
    end

    it "should set the duplicate flag of the packet correctly" do
      expect(packet.duplicate).to be === false
    end

    it "should set the retain flag of the packet correctly" do
      expect(packet.retain).to be === false
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to be === :short
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to be === 'tt'
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to be === 0x0000
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.data).to eq("Hello World")
    end
  end

  describe "when parsing a Publish packet with a predefined topic id type" do
    let(:packet) { MQTT::SN::Packet.parse("\x12\x0C\x01\x00\xEE\x00\x00Hello World") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Publish)
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to eql(:predefined)
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to eq(0xEE)
    end
  end

  describe "when parsing a Publish packet with a invalid topic id type" do
    let(:packet) { MQTT::SN::Packet.parse("\x12\x0C\x03\x00\x10\x55\xCCHello World") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Publish)
    end

    it "should set the QoS value of the packet correctly" do
      expect(packet.qos).to be === 0
    end

    it "should set the duplicate flag of the packet correctly" do
      expect(packet.duplicate).to be === false
    end

    it "should set the retain flag of the packet correctly" do
      expect(packet.retain).to be === false
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to be_nil
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to eq(0x10)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to be === 0x55CC
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.data).to eq("Hello World")
    end
  end

  describe "when parsing a Publish packet longer than 256 bytes" do
    let(:packet) { MQTT::SN::Packet.parse("\x01\x04\x55\x0C\x62tt\x00\x00" + ("Hello World" * 100)) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Publish)
    end

    it "should set the QoS value of the packet correctly" do
      expect(packet.qos).to be === -1
    end

    it "should set the duplicate flag of the packet correctly" do
      expect(packet.duplicate).to be === false
    end

    it "should set the retain flag of the packet correctly" do
      expect(packet.retain).to be === false
    end

    it "should set the topic id type of the packet correctly" do
      expect(packet.topic_id_type).to be === :short
    end

    it "should set the topic id of the packet correctly" do
      expect(packet.topic_id).to be === 'tt'
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to be === 0x0000
    end

    it "should set the topic name of the packet correctly" do
      expect(packet.data).to eq("Hello World" * 100)
    end
  end
end
