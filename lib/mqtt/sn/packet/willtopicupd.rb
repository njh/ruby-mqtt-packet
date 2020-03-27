# encoding: BINARY

class MQTT::SN::Packet::Willtopicupd < MQTT::SN::Packet
  attr_accessor :topic_name

  DEFAULTS = {
    :qos => 0,
    :retain => false,
    :topic_name => nil
  }

  def encode_body
    if topic_name.nil? || topic_name.empty?
      ''
    else
      [encode_flags, topic_name].pack('Ca*')
    end
  end

  def parse_body(buffer)
    if buffer.length > 1
      flags, self.topic_name = buffer.unpack('Ca*')
      parse_flags(flags)
    else
      self.topic_name = nil
    end
  end
end

