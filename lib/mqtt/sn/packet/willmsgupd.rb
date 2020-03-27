# encoding: BINARY

class MQTT::SN::Packet::Willmsgupd < MQTT::SN::Packet
  attr_accessor :data

  def encode_body
    data
  end

  def parse_body(buffer)
    self.data = buffer
  end
end

