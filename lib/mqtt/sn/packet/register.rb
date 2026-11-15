# encoding: BINARY

class MQTT::SN::Packet::Register < MQTT::SN::Packet
  attr_accessor :id
  attr_accessor :topic_id
  attr_accessor :topic_name

  DEFAULTS = {
    :id => 0x00,
    :topic_id_type => :normal
  }

  def encode_body
    raise 'id must be an Integer' unless id.is_a?(Integer)

    raise 'topic_id must be an Integer' unless topic_id.is_a?(Integer)

    [topic_id, id, topic_name].pack('nna*')
  end

  def parse_body(buffer)
    self.topic_id, self.id, self.topic_name = buffer.unpack('nna*')
  end
end
