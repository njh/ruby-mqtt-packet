# encoding: BINARY

# Class representing an MQTT Connect Acknowledgment Packet
class MQTT::Packet::Connack < MQTT::Packet
  # Session Present flag
  attr_accessor :session_present

  # The return code (defaults to 0 for connection accepted)
  attr_accessor :return_code

  # Default attribute values
  ATTR_DEFAULTS = { :return_code => 0x00 }

  # Create a new Client Connect packet
  def initialize(args = {})
    # We must set flags before other attributes
    @connack_flags = [false, false, false, false, false, false, false, false]
    super(ATTR_DEFAULTS.merge(args))
  end

  # Get the Session Present flag
  def session_present
    @connack_flags[0]
  end

  # Set the Session Present flag
  def session_present=(arg)
    @connack_flags[0] = arg.is_a?(Integer) ? (arg == 0x1) : arg
  end

  # Get a string message corresponding to a return code
  def return_msg
    case return_code
    when 0x00
      'Connection Accepted'
    when 0x01
      'Connection refused: unacceptable protocol version'
    when 0x02
      'Connection refused: client identifier rejected'
    when 0x03
      'Connection refused: server unavailable'
    when 0x04
      'Connection refused: bad user name or password'
    when 0x05
      'Connection refused: not authorised'
    else
      "Connection refused: error code #{return_code}"
    end
  end

  # Get serialisation of packet's body
  def encode_body
    body = ''
    body += encode_bits(@connack_flags)
    body += encode_bytes(@return_code.to_i)
    body
  end

  # Parse the body (variable header and payload) of a Connect Acknowledgment packet
  def parse_body(buffer)
    super(buffer)
    @connack_flags = shift_bits(buffer)
    unless @connack_flags[1, 7] == [false, false, false, false, false, false, false]
      raise ParseException, 'Invalid flags in Connack variable header'
    end
    @return_code = shift_byte(buffer)

    return if buffer.empty?
    raise ParseException, 'Extra bytes at end of Connect Acknowledgment packet'
  end

  # Returns a human readable string, summarising the properties of the packet
  def inspect
    "\#<#{self.class}: 0x%2.2X>" % return_code
  end
end
