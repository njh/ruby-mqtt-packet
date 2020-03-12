# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet'

describe MQTT::Packet::Suback do
  describe "when serialising a packet" do
    it "should output the correct bytes for an acknowledgement to a single topic" do
      packet = MQTT::Packet::Suback.new( :id => 5, :return_codes => 0 )
      expect(packet.to_s).to eq("\x90\x03\x00\x05\x00")
    end

    it "should output the correct bytes for an acknowledgement to a two topics" do
      packet = MQTT::Packet::Suback.new( :id => 6 , :return_codes => [0,1] )
      expect(packet.to_s).to eq("\x90\x04\x00\x06\x00\x01")
    end

    it "should raise an exception when no granted QoSs are given" do
      expect {
        MQTT::Packet::Suback.new( :id => 7 ).to_s
      }.to raise_error(
        'no granted QoS given when serialising packet'
      )
    end

    it "should raise an exception if the granted QoS is not an integer" do
      expect {
        MQTT::Packet::Suback.new( :id => 8, :return_codes => :foo ).to_s
      }.to raise_error(
        'return_codes should be an integer or an array of return codes'
      )
    end
  end

  describe "when parsing a packet with a single QoS value of 0" do
    let(:packet) { MQTT::Packet.parse( "\x90\x03\x12\x34\x00" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Suback)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x1234)
    end

    it "should set the Granted QoS of the packet correctly" do
      expect(packet.return_codes).to eq([0])
    end
  end

  describe "when parsing a packet with two QoS values" do
    let(:packet) { MQTT::Packet.parse( "\x90\x04\x12\x34\x01\x01" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Suback)
    end

    it "should set the message id of the packet correctly" do
      expect(packet.id).to eq(0x1234)
    end

    it "should set the Granted QoS of the packet correctly" do
      expect(packet.return_codes).to eq([1,1])
    end
  end

  describe "when parsing packet with invalid fixed header flags" do
    it "should raise a protocol exception" do
      expect {
        MQTT::Packet.parse( "\x92\x03\x12\x34\x00" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Invalid flags in SUBACK packet header"
      )
    end
  end

  describe "when calling the inspect method" do
    it "should output correct string for a single granted qos" do
      packet = MQTT::Packet::Suback.new(:id => 0x1234, :return_codes => 0)
      expect(packet.inspect).to eq("#<MQTT::Packet::Suback: 0x1234, rc=0x00>")
    end

    it "should output correct string for multiple topics" do
      packet = MQTT::Packet::Suback.new(:id => 0x1235, :return_codes => [0,1,2])
      expect(packet.inspect).to eq("#<MQTT::Packet::Suback: 0x1235, rc=0x00,0x01,0x02>")
    end
  end

  describe "deprecated attributes" do
    it "should still have a granted_qos method that is that same as return_codes" do
      packet = MQTT::Packet::Suback.new
      packet.granted_qos = [0,1,2]
      expect(packet.granted_qos).to eq([0,1,2])
      expect(packet.return_codes).to eq([0,1,2])
      packet.return_codes = [0,1,0]
      expect(packet.granted_qos).to eq([0,1,0])
      expect(packet.return_codes).to eq([0,1,0])
    end
  end
end
