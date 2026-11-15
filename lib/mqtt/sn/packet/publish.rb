# encoding: BINARY

class MQTT::SN::Packet::Publish < MQTT::SN::Packet
  attr_accessor :topic_id
  attr_accessor :id
  attr_accessor :data

  DEFAULTS = {
    :id => 0x00,
    :duplicate => false,
    :qos => 0,
    :retain => false,
    :topic_id_type => :normal
  }

  def encode_body
    raise 'id must be an Integer' unless id.is_a?(Integer)

    [encode_flags, encode_topic_id, id, data].pack('Cnna*')
  end

  def parse_body(buffer)
    flags, topic_id, self.id, self.data = buffer.unpack('Cnna*')
    parse_flags(flags)
    parse_topic_id(topic_id)
  end
end
