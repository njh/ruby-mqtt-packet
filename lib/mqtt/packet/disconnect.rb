# encoding: BINARY

# Class representing an MQTT Client Disconnect packet
class MQTT::Packet::Disconnect < MQTT::Packet
  # Create a new Client Disconnect packet
  def initialize(args = {})
    super(args)
  end

  # Check the body
  def parse_body(buffer)
    super(buffer)

    return if buffer.empty?
    raise ParseException, 'Extra bytes at end of Disconnect packet'
  end
end
