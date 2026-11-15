# encoding: BINARY
# Encoding is set to binary, so that the binary packets aren't validated as UTF-8

$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/sn/packet'

describe MQTT::SN::Packet::Connect do
  it "should have the right type id" do
    packet = MQTT::SN::Packet::Connect.new
    expect(packet.type_id).to eq(0x04)
  end

  describe "when serialising a packet" do
    it "should output the correct bytes for a packet with no flags" do
      packet = MQTT::SN::Packet::Connect.new(
        :client_id => 'mqtt-sn-client-pub'
      )
      expect(packet.to_s).to eq("\x18\x04\x04\x01\x00\x0fmqtt-sn-client-pub")
    end

    it "should output the correct bytes for a packet with clean session turned off" do
      packet = MQTT::SN::Packet::Connect.new(
        :client_id => 'myclient',
        :clean_session => false
      )
      expect(packet.to_s).to eq("\016\004\000\001\000\017myclient")
    end

    it "should raise an exception when there is no client identifier" do
      expect {
        MQTT::SN::Packet::Connect.new.to_s
      }.to raise_error(
        'Invalid client identifier when serialising packet'
      )
    end

    it "should output the correct bytes for a packet with a will request" do
      packet = MQTT::SN::Packet::Connect.new(
        :client_id => 'myclient',
        :request_will => true,
        :clean_session => true
      )
      expect(packet.to_s).to eq("\016\004\014\001\000\017myclient")
    end

    it "should output the correct bytes for with a custom keep alive" do
      packet = MQTT::SN::Packet::Connect.new(
        :client_id => 'myclient',
        :request_will => true,
        :clean_session => true,
        :keep_alive => 30
      )
      expect(packet.to_s).to eq("\016\004\014\001\000\036myclient")
    end
  end

  describe "when parsing a simple Connect packet" do
    let(:packet) { MQTT::SN::Packet.parse("\x18\x04\x04\x01\x00\x00mqtt-sn-client-pub") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Connect)
    end

    it "should not have the request will flag set" do
      expect(packet.request_will).to be_falsy
    end

    it "shoul have the clean session flag set" do
      expect(packet.clean_session).to be_truthy
    end

    it "should set the Keep Alive timer of the packet correctly" do
      expect(packet.keep_alive).to eq(0)
    end

    it "should set the Client Identifier of the packet correctly" do
      expect(packet.client_id).to eq('mqtt-sn-client-pub')
    end
  end

  describe "when parsing a Connect packet with the clean session flag set" do
    let(:packet) { MQTT::SN::Packet.parse("\016\004\004\001\000\017myclient") }

    it "should set the clean session flag" do
      expect(packet.clean_session).to be_truthy
    end
  end

  describe "when parsing a Connect packet with the will request flag set" do
    let(:packet) { MQTT::SN::Packet.parse("\016\004\014\001\000\017myclient") }

    it "should correctly create the right type of packet object" do
      expect(packet.class).to eq(MQTT::SN::Packet::Connect)
    end
    it "should set the Client Identifier of the packet correctly" do
      expect(packet.client_id).to eq('myclient')
    end

    it "should set the clean session flag should be set" do
      expect(packet.clean_session).to be_truthy
    end

    it "should set the Will retain flag should be false" do
      expect(packet.request_will).to be_truthy
    end
  end

  context "that has an invalid type identifier" do
    it "should raise an exception" do
      expect {
        MQTT::SN::Packet.parse("\x02\xFF")
      }.to raise_error(
        MQTT::SN::Packet::ParseException,
        "Invalid packet type identifier: 255"
      )
    end
  end

  describe "when parsing a Connect packet an unsupport protocol ID" do
    it "should raise an exception" do
      expect {
        packet = MQTT::SN::Packet.parse(
          "\016\004\014\005\000\017myclient"
        )
      }.to raise_error(
        MQTT::SN::Packet::ParseException,
        "Unsupported protocol ID number: 5"
      )
    end
  end
end

