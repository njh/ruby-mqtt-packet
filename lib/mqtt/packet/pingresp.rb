# encoding: BINARY

# Class representing an MQTT Ping Response packet
class MQTT::Packet::Pingresp < MQTT::Packet
  # Create a new Ping Response packet
  def initialize(args = {})
    super(args)
  end

  # Check the body
  def parse_body(buffer)
    super(buffer)

    return if buffer.empty?
    raise ParseException, 'Extra bytes at end of Ping Response packet'
  end
end
