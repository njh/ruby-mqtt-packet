# encoding: BINARY

class MQTT::SN::Packet::Advertise < MQTT::SN::Packet
  attr_accessor :gateway_id
  attr_accessor :duration

  DEFAULTS = {
    :gateway_id => 0x00,
    :duration => 0
  }

  def encode_body
    [gateway_id, duration].pack('Cn')
  end

  def parse_body(buffer)
    self.gateway_id, self.duration = buffer.unpack('Cn')
  end
end

