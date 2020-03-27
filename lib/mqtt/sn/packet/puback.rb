# encoding: BINARY

class MQTT::SN::Packet::Puback < MQTT::SN::Packet
  attr_accessor :topic_id
  attr_accessor :id
  attr_accessor :return_code

  DEFAULTS = {
    :id => 0x00,
    :topic_id => nil,
    :return_code => 0x00
  }

  def encode_body
    raise 'id must be an Integer' unless id.is_a?(Integer)

    raise 'topic_id must be an Integer' unless topic_id.is_a?(Integer)

    [topic_id, id, return_code].pack('nnC')
  end

  def parse_body(buffer)
    self.topic_id, self.id, self.return_code = buffer.unpack('nnC')
  end
end

