# encoding: BINARY

class MQTT::SN::Packet::Unsuback < MQTT::SN::Packet
  attr_accessor :id

  DEFAULTS = {
    :id => 0x00
  }

  def encode_body
    raise 'id must be an Integer' unless id.is_a?(Integer)

    [id].pack('n')
  end

  def parse_body(buffer)
    self.id = buffer.unpack('n').first
  end
end

