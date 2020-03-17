# encoding: BINARY

# Class representing an MQTT Publish message
class MQTT::Packet::Publish < MQTT::Packet
  # Duplicate delivery flag
  attr_accessor :duplicate

  # Retain flag
  attr_accessor :retain

  # Quality of Service level (0, 1, 2)
  attr_accessor :qos

  # The topic name to publish to
  attr_accessor :topic

  # The data to be published
  attr_accessor :payload

  # Default attribute values
  ATTR_DEFAULTS = {
    :topic => nil,
    :payload => ''
  }

  # Create a new Publish packet
  def initialize(args = {})
    super(ATTR_DEFAULTS.merge(args))
  end

  def duplicate
    @flags[3]
  end

  # Set the DUP flag (true/false)
  def duplicate=(arg)
    @flags[3] = arg.is_a?(Integer) ? (arg == 0x1) : arg
  end

  def retain
    @flags[0]
  end

  # Set the retain flag (true/false)
  def retain=(arg)
    @flags[0] = arg.is_a?(Integer) ? (arg == 0x1) : arg
  end

  def qos
    (@flags[1] ? 0x01 : 0x00) | (@flags[2] ? 0x02 : 0x00)
  end

  # Set the Quality of Service level (0/1/2)
  def qos=(arg)
    @qos = arg.to_i
    raise "Invalid QoS value: #{@qos}" if @qos < 0 || @qos > 2

    @flags[1] = (arg & 0x01 == 0x01)
    @flags[2] = (arg & 0x02 == 0x02)
  end

  # Get serialisation of packet's body
  def encode_body
    body = ''
    if @topic.nil? || @topic.to_s.empty?
      raise 'Invalid topic name when serialising packet'
    end
    body += encode_string(@topic)
    body += encode_short(@id) unless qos.zero?
    body += payload.to_s.dup.force_encoding('ASCII-8BIT')
    body
  end

  # Parse the body (variable header and payload) of a Publish packet
  def parse_body(buffer)
    super(buffer)
    @topic = shift_string(buffer)
    @id = shift_short(buffer) unless qos.zero?
    @payload = buffer
  end

  # Check that fixed header flags are valid for this packet type
  # @private
  def validate_flags
    raise ParseException, 'Invalid packet: QoS value of 3 is not allowed' if qos == 3
    raise ParseException, 'Invalid packet: DUP cannot be set for QoS 0' if qos.zero? && duplicate
  end

  # Returns a human readable string, summarising the properties of the packet
  def inspect
    "\#<#{self.class}: " \
      "d#{duplicate ? '1' : '0'}, " \
      "q#{qos}, " \
      "r#{retain ? '1' : '0'}, " \
      "m#{id}, " \
      "'#{topic}', " \
      "#{inspect_payload}>"
  end

  protected

  def inspect_payload
    str = payload.to_s
    if str.bytesize < 16 && str =~ /^[ -~]*$/
      "'#{str}'"
    else
      "... (#{str.bytesize} bytes)"
    end
  end
end
