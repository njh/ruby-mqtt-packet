# encoding: BINARY

class MQTT::SN::Packet::Disconnect < MQTT::SN::Packet
  attr_accessor :duration

  DEFAULTS = {
    :duration => nil
  }

  def encode_body
    if duration.nil? || duration.zero?
      ''
    else
      [duration].pack('n')
    end
  end

  def parse_body(buffer)
    self.duration = buffer.length == 2 ? buffer.unpack('n').first : nil
  end
end
