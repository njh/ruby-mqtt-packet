# encoding: BINARY

class MQTT::SN::Packet::Gwinfo < MQTT::SN::Packet
  attr_accessor :gateway_id
  attr_accessor :gateway_address

  DEFAULTS = {
    :gateway_id => 0,
    :gateway_address => nil
  }

  def encode_body
    [gateway_id, gateway_address].pack('Ca*')
  end

  def parse_body(buffer)
    if buffer.length > 1
      self.gateway_id, self.gateway_address = buffer.unpack('Ca*')
    else
      self.gateway_id, _ignore = buffer.unpack('C')
      self.gateway_address = nil
    end
  end
end
