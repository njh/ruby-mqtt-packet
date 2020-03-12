# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet'

describe MQTT::Packet do
  describe "when creating a new packet" do
    it "should allow you to set the packet flags as a hash parameter" do
      packet = MQTT::Packet.new( :flags => [true, false, true, false] )
      expect(packet.flags).to eq([true, false, true, false])
    end

    it "should have a custom inspect method" do
      packet = MQTT::Packet.new
      expect(packet.inspect).to eq('#<MQTT::Packet>')
    end

    it "should have a type_id method to get the integer ID of the packet type" do
      packet = MQTT::Packet::Pingreq.new
      expect(packet.type_id).to eq(12)
    end
  end

  it "should let you change attributes using the update_attributes method" do
    packet = MQTT::Packet.new(:flags => [false, false, false, true])
    packet.update_attributes(:flags => [false, false, true, true])
    expect(packet.flags).to eq([false, false, true, true])
  end

  describe "protected methods" do
    let(:packet) { MQTT::Packet.new }

    it "should provide a encode_bytes method to get some bytes as Integers" do
      data = packet.send(:encode_bytes, 0x48, 0x65, 0x6c, 0x6c, 'o'.unpack('C1')[0])
      expect(data).to eq('Hello')
    end

    it "should provide a encode_bits method to encode an array of bits to a string" do
      data = packet.send(:encode_bits, [false, true, true, false, true, false, true, false])
      expect(data).to eq('V')
    end

    it "should provide a add_short method to get a big-endian unsigned 16-bit integer" do
      data = packet.send(:encode_short, 1024)
      expect(data).to eq("\x04\x00")
      expect(data.encoding.to_s).to eq("ASCII-8BIT")
    end

    it "should raise an error if too big argument for encode_short" do
      expect {
        data = packet.send(:encode_short, 0x10000)
      }.to raise_error(
        'Value too big for short'
      )
    end

    it "should provide a add_string method to get a string preceeded by its length" do
      data = packet.send(:encode_string, 'quack')
      expect(data).to eq("\x00\x05quack")
      expect(data.encoding.to_s).to eq("ASCII-8BIT")
    end

    it "should provide a shift_short method to get a 16-bit unsigned integer" do
      buffer = "\x22\x8Bblahblah"
      expect(packet.send(:shift_short,buffer)).to eq(8843)
      expect(buffer).to eq('blahblah')
    end

    it "should provide a shift_byte method to get one byte as integers" do
      buffer = "\x01blahblah"
      expect(packet.send(:shift_byte,buffer)).to eq(1)
      expect(buffer).to eq('blahblah')
    end

    it "should provide a shift_byte method to get one byte as integers" do
      buffer = "Yblahblah"
      expect(packet.send(:shift_bits, buffer)).to eq([true, false, false, true, true, false, true, false])
      expect(buffer).to eq('blahblah')
    end

    it "should provide a shift_string method to get a string preceeded by its length" do
      buffer = "\x00\x05Hello World"
      expect(packet.send(:shift_string,buffer)).to eq("Hello")
      expect(buffer).to eq(' World')
    end
  end

  describe "deprecated attributes" do
    it "should still have a message_id method that is that same as id" do
      packet = MQTT::Packet.new
      packet.message_id = 1234
      expect(packet.message_id).to eq(1234)
      expect(packet.id).to eq(1234)
      packet.id = 4321
      expect(packet.message_id).to eq(4321)
      expect(packet.id).to eq(4321)
    end
  end

  context "Serialising an invalid packet" do
    context "that has a no type" do
      it "should raise an exception" do
        expect {
          MQTT::Packet.new.to_s
        }.to raise_error(
          RuntimeError,
          "Invalid packet type: MQTT::Packet"
        )
      end
    end
  end

  context "Reading in an invalid packet from a socket" do
    context "that has 0 length" do
      it "should raise an exception" do
        expect {
          socket = StringIO.new
          MQTT::Packet.read(socket)
        }.to raise_error(
          MQTT::Packet::ParseException,
          "Failed to read byte from socket"
        )
      end
    end

    context "that has an incomplete packet length header" do
      it "should raise an exception" do
        expect {
          socket = StringIO.new("\x30\xFF")
          MQTT::Packet.read(socket)
        }.to raise_error(
          MQTT::Packet::ParseException,
          "Failed to read byte from socket"
        )
      end
    end

    context "that has the maximum number of bytes in the length header" do
      it "should raise an exception" do
        expect {
          socket = StringIO.new("\x30\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF")
          MQTT::Packet.read(socket)
        }.to raise_error(
          MQTT::Packet::ParseException,
          "Failed to parse packet - input buffer (4) is not the same as the body length header (268435455)"
        )
      end
    end
  end

  context "Parsing an invalid packet" do
    context "that has no length" do
      it "should raise an exception" do
        expect {
          MQTT::Packet.parse( "" )
        }.to raise_error(
          MQTT::Packet::ParseException,
          "Invalid packet: less than 2 bytes long"
        )
      end
    end

    context "that has an invalid type identifier" do
      it "should raise an exception" do
        expect {
          MQTT::Packet.parse( "\x00\x00" )
        }.to raise_error(
          MQTT::Packet::ParseException,
          "Invalid packet type identifier: 0"
        )
      end
    end

    context "that has an incomplete packet length header" do
      it "should raise an exception" do
        expect {
          MQTT::Packet.parse( "\x30\xFF" )
        }.to raise_error(
          MQTT::Packet::ParseException,
          "The packet length header is incomplete"
        )
      end
    end

    context "that has too many bytes in the length field" do
      it "should raise an exception" do
        expect {
          MQTT::Packet.parse( "\x30\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" )
        }.to raise_error(
          MQTT::Packet::ParseException,
          'Failed to parse packet - input buffer (4) is not the same as the body length header (268435455)'
        )
      end
    end

    context "that has a bigger buffer than expected" do
      it "should raise an exception" do
        expect {
          MQTT::Packet.parse( "\x30\x11\x00\x04testhello big world" )
        }.to raise_error(
          MQTT::Packet::ParseException,
          "Failed to parse packet - input buffer (21) is not the same as the body length header (17)"
        )
      end
    end

    context "that has a smaller buffer than expected" do
      it "should raise an exception" do
        expect {
          MQTT::Packet.parse( "\x30\x11\x00\x04testhello" )
        }.to raise_error(
          MQTT::Packet::ParseException,
          "Failed to parse packet - input buffer (11) is not the same as the body length header (17)"
        )
      end
    end
  end
end
