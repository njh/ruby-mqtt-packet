# encoding: BINARY

# Class representing an MQTT Ping Request packet
class MQTT::Packet::Pingreq < MQTT::Packet
  # Create a new Ping Request packet
  def initialize(args = {})
    super(args)
  end

  # Check the body
  def parse_body(buffer)
    super(buffer)

    return if buffer.empty?
    raise ParseException, 'Extra bytes at end of Ping Request packet'
  end
end
