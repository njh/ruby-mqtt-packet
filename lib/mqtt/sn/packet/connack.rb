# encoding: BINARY

class MQTT::SN::Packet::Connack < MQTT::SN::Packet
  attr_accessor :return_code

  # Get a string message corresponding to a return code
  def return_msg
    case return_code
    when 0x00
      'Accepted'
    when 0x01
      'Rejected: congestion'
    when 0x02
      'Rejected: invalid topic ID'
    when 0x03
      'Rejected: not supported'
    else
      "Rejected: error code #{return_code}"
    end
  end

  def encode_body
    raise 'return_code must be an Integer' unless return_code.is_a?(Integer)

    [return_code].pack('C')
  end

  def parse_body(buffer)
    self.return_code = buffer.unpack('C')[0]
  end
end

