# encoding: BINARY

class MQTT::SN::Packet::Searchgw < MQTT::SN::Packet
  attr_accessor :radius

  DEFAULTS = {
    :radius => 1
  }

  def encode_body
    [radius].pack('C')
  end

  def parse_body(buffer)
    self.radius, _ignore = buffer.unpack('C')
  end
end

