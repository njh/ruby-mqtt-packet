$:.unshift(File.dirname(__FILE__))

require 'spec_helper'
require 'mqtt/packet/version'

describe MQTT::Packet do
  describe "version number" do
    it "should be defined as a constant" do
      expect(defined?(MQTT::Packet::VERSION)).to eq('constant')
    end

    it "should be a string" do
      expect(MQTT::Packet::VERSION).to be_a(String)
    end

    it "should be in the format x.y.z" do
      expect(MQTT::Packet::VERSION).to match(/^\d{1,2}\.\d{1,2}\.\d{1,2}$/)
    end

  end
end
