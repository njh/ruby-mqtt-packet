# encoding: BINARY

class MQTT::SN::Packet::Willmsg < MQTT::SN::Packet
  attr_accessor :data

  def encode_body
    data
  end

  def parse_body(buffer)
    self.data = buffer
  end
end

