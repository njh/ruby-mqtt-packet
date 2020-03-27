# encoding: BINARY

class MQTT::SN::Packet::Suback < MQTT::SN::Packet
  attr_accessor :id
  attr_accessor :topic_id
  attr_accessor :return_code

  DEFAULTS = {
    :qos => 0,
    :id => 0x00,
    :topic_id => 0x00,
    :topic_id_type => :normal
  }

  def encode_body
    raise 'id must be an Integer' unless id.is_a?(Integer)

    [encode_flags, encode_topic_id, id, return_code].pack('CnnC')
  end

  def parse_body(buffer)
    flags, topic_id, self.id, self.return_code = buffer.unpack('CnnC')
    parse_flags(flags)
    parse_topic_id(topic_id)
  end
end
