# encoding: BINARY

# Class representing an MQTT Publish Release packet
class MQTT::Packet::Pubrel < MQTT::Packet
  # Default attribute values
  ATTR_DEFAULTS = {
    :flags => [false, true, false, false]
  }

  # Create a new Pubrel packet
  def initialize(args = {})
    super(ATTR_DEFAULTS.merge(args))
  end

  # Get serialisation of packet's body
  def encode_body
    encode_short(@id)
  end

  # Parse the body (variable header and payload) of a packet
  def parse_body(buffer)
    super(buffer)
    @id = shift_short(buffer)

    return if buffer.empty?
    raise ParseException, 'Extra bytes at end of Publish Release packet'
  end

  # Check that fixed header flags are valid for this packet type
  # @private
  def validate_flags
    return if @flags == [false, true, false, false]
    raise ParseException, 'Invalid flags in PUBREL packet header'
  end

  # Returns a human readable string, summarising the properties of the packet
  def inspect
    "\#<#{self.class}: 0x%2.2X>" % id
  end
end
