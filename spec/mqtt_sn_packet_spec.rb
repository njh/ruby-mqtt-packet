# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet do
  describe "when creating a new packet" do
    it "should allow you to set the packet dup flag as a hash parameter" do
      packet = MQTT::SN::Packet.new(:duplicate => true)
      expect(packet.duplicate).to be_truthy
    end

    it "should allow you to set the packet QoS level as a hash parameter" do
      packet = MQTT::SN::Packet.new(:qos => 2)
      expect(packet.qos).to eq(2)
    end

    it "should allow you to set the packet retain flag as a hash parameter" do
      packet = MQTT::SN::Packet.new(:retain => true)
      expect(packet.retain).to be_truthy
    end
  end

  describe "getting the type id on a un-subclassed packet" do
    it "should raise an exception" do
      expect {
        MQTT::SN::Packet.new.type_id
      }.to raise_error(
        RuntimeError,
        "Invalid packet type: MQTT::SN::Packet"
      )
    end
  end

  describe "Parsing a packet that does not match the packet length" do
    it "should raise an exception" do
      expect {
        packet = MQTT::SN::Packet.parse("\x02\x1834567")
      }.to raise_error(
        MQTT::SN::Packet::ParseException,
        "Length of packet is not the same as the length header"
      )
    end
  end
end
