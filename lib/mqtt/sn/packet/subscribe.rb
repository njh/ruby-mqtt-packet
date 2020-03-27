# encoding: BINARY

class MQTT::SN::Packet::Subscribe < MQTT::SN::Packet
  attr_accessor :id
  attr_accessor :topic_id
  attr_accessor :topic_name

  DEFAULTS = {
    :id => 0x00,
    :topic_id_type => :normal
  }

  def encode_body
    raise 'id must be an Integer' unless id.is_a?(Integer)

    [encode_flags, id, encode_topic].pack('Cna*')
  end

  def parse_body(buffer)
    flags, self.id, topic = buffer.unpack('Cna*')
    parse_flags(flags)
    parse_topic(topic)
  end
end
