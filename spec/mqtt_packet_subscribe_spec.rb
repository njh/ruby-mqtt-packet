# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet'

describe MQTT::Packet::Subscribe do
  describe "setting the packet's topics" do
    let(:packet)  { MQTT::Packet::Subscribe.new }

    it "should be able to set the topics from a String 'a/b'" do
      packet.topics = 'a/b'
      expect(packet.topics).to eq([["a/b", 0]])
    end

    it "should be able to set the multiple topics from an array ['a/b', 'b/c']" do
      packet.topics = ['a/b', 'b/c']
      expect(packet.topics).to eq([["a/b", 0], ['b/c', 0]])
    end

    it "should be able to set the topics from a Hash {'a/b' => 0, 'b/c' => 1}" do
      packet.topics = {'a/b' => 0, 'b/c' => 1}
      expect(packet.topics).to eq([["a/b", 0], ["b/c", 1]])
    end

    it "should be able to set the topics from a single level array ['a/b', 0]" do
      packet.topics = ['a/b', 0]
      expect(packet.topics).to eq([["a/b", 0]])
    end

    it "should be able to set the topics from a two level array [['a/b' => 0], ['b/c' => 1]]" do
      packet.topics = [['a/b', 0], ['b/c', 1]]
      expect(packet.topics).to eq([['a/b', 0], ['b/c', 1]])
    end

    it "should raise an exception when setting topic with a non-string" do
      expect {
        packet.topics = 56
      }.to raise_error(
        'Invalid topics input: 56'
      )
    end
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a packet with a single topic" do
      packet = MQTT::Packet::Subscribe.new( :id => 1, :topics => 'a/b' )
      expect(packet.to_s).to eq("\x82\x08\x00\x01\x00\x03a/b\x00")
    end

    it "should output the correct bytes for a packet with multiple topics" do
      packet = MQTT::Packet::Subscribe.new( :id => 6, :topics => [['a/b', 0], ['c/d', 1]] )
      expect(packet.to_s).to eq("\x82\x0e\000\x06\x00\x03a/b\x00\x00\x03c/d\x01")
    end

    it "should raise an exception when no topics are given" do
      expect {
        MQTT::Packet::Subscribe.new.to_s
      }.to raise_error(
        'no topics given when serialising packet'
      )
    end
  end

  describe "when parsing a packet with a single topic" do
    let(:packet) { MQTT::Packet.parse( "\x82\x08\x00\x01\x00\x03a/b\x00" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Subscribe)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, true, false, false])
    end

    it "should set the Message ID correctly" do
      expect(packet.id).to eq(1)
    end

    it "should set the topic name correctly" do
      expect(packet.topics).to eq([['a/b',0]])
    end
  end

  describe "when parsing a packet with a two topics" do
    let(:packet) { MQTT::Packet.parse( "\x82\x0e\000\x06\x00\x03a/b\x00\x00\x03c/d\x01" ) }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::Packet::Subscribe)
    end

    it "should set the fixed header flags of the packet correctly" do
      expect(packet.flags).to eq([false, true, false, false])
    end

    it "should set the Message ID correctly" do
      expect(packet.id).to eq(6)
    end

    it "should set the topic name correctly" do
      expect(packet.topics).to eq([['a/b',0],['c/d',1]])
    end
  end

  describe "when parsing packet with invalid fixed header flags" do
    it "should raise a protocol exception" do
      expect {
        MQTT::Packet.parse( "\x80\x08\x00\x01\x00\x03a/b\x00" )
      }.to raise_error(
        MQTT::Packet::ParseException,
        "Invalid flags in SUBSCRIBE packet header"
      )
    end
  end

  describe "when calling the inspect method" do
    it "should output correct string for a single topic" do
      packet = MQTT::Packet::Subscribe.new(:topics => 'test')
      expect(packet.inspect).to eq("#<MQTT::Packet::Subscribe: 0x00, 'test':0>")
    end

    it "should output correct string for multiple topics" do
      packet = MQTT::Packet::Subscribe.new(:topics => {'a' => 1, 'b' => 0, 'c' => 2})
      expect(packet.inspect).to eq("#<MQTT::Packet::Subscribe: 0x00, 'a':1, 'b':0, 'c':2>")
    end
  end
end
