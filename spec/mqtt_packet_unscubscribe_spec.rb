# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet'

describe MQTT::Packet::Unsubscribe do
  describe "when serialising a packet" do
    it "should output the correct bytes for a packet with single topic" do
      packet = MQTT::Packet::Unsubscribe.new( :id => 5, :topics => 'a/b' )
      expect(packet.to_s).to eq("\xa2\x07\x00\x05\x00\x03a/b")
    end

    it "should output the correct bytes for a packet with multiple topics" do
      packet = MQTT::Packet::Unsubscribe.new( :id => 6, :topics => ['a/b','c/d'] )
      expect(packet.to_s).to eq("\xa2\x0c\000\006\000\003a/b\000\003c/d")
    end

    it "should raise an exception when no topics are given" do
      expect {
        MQTT::Packet::Unsubscribe.new.to_s
      }.to raise_error(
        'no topics given when serialising packet'
      )
    end
  end

  describe "when parsing a packet" do
    let(:packet) { MQTT::Packet.parse( "\xa2\f\000\005\000\003a/b\000\003c/d" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Unsubscribe)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, true, false, false])
    end

    it "should set the topic name correctly" do
      expect(packet.topics).to eq(['a/b','c/d'])
    end
  end

  describe "when parsing packet with invalid fixed header flags" do
    it "should raise a protocol exception" do
      expect {
        MQTT::Packet.parse( "\xa0\x07\x00\x05\x00\x03a/b" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Invalid flags in UNSUBSCRIBE packet header"
      )
    end
  end

  describe "when calling the inspect method" do
    it "should output correct string for a single topic" do
      packet = MQTT::Packet::Unsubscribe.new(:topics => 'test')
      expect(packet.inspect).to eq("#<MQTT::Packet::Unsubscribe: 0x00, 'test'>")
    end

    it "should output correct string for multiple topics" do
      packet = MQTT::Packet::Unsubscribe.new( :id => 42, :topics => ['a', 'b', 'c'] )
      expect(packet.inspect).to eq("#<MQTT::Packet::Unsubscribe: 0x2A, 'a', 'b', 'c'>")
    end
  end
end

