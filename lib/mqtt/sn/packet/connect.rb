# encoding: BINARY

class MQTT::SN::Packet::Connect < MQTT::SN::Packet
  attr_accessor :keep_alive
  attr_accessor :client_id

  DEFAULTS = {
    :request_will => false,
    :clean_session => true,
    :keep_alive => 15
  }

  # Get serialisation of packet's body
  def encode_body
    if @client_id.nil? || @client_id.empty? || @client_id.length > 23
      raise 'Invalid client identifier when serialising packet'
    end

    [encode_flags, 0x01, keep_alive, client_id].pack('CCna*')
  end

  def parse_body(buffer)
    flags, protocol_id, self.keep_alive, self.client_id = buffer.unpack('CCna*')

    if protocol_id != 0x01
      raise ParseException, "Unsupported protocol ID number: #{protocol_id}"
    end

    parse_flags(flags)
  end
end
