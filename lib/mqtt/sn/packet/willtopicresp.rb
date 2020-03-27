# encoding: BINARY

class MQTT::SN::Packet::Willtopicresp < MQTT::SN::Packet
  attr_accessor :return_code

  DEFAULTS = {
    :return_code => 0x00
  }

  def encode_body
    raise 'return_code must be an Integer' unless return_code.is_a?(Integer)

    [return_code].pack('C')
  end

  def parse_body(buffer)
    self.return_code, _ignore = buffer.unpack('C')
  end
end

