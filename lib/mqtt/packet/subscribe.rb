# encoding: BINARY

# Class representing an MQTT Client Subscribe packet
class MQTT::Packet::Subscribe < MQTT::Packet
  # One or more topic filters to subscribe to
  attr_accessor :topics

  # Default attribute values
  ATTR_DEFAULTS = {
    :topics => [],
    :flags => [false, true, false, false]
  }

  # Create a new Subscribe packet
  def initialize(args = {})
    super(ATTR_DEFAULTS.merge(args))
  end

  # Set one or more topic filters for the Subscribe packet
  # The topics parameter should be one of the following:
  # * String: subscribe to one topic with QoS 0
  # * Array: subscribe to multiple topics with QoS 0
  # * Hash: subscribe to multiple topics where the key is the topic and the value is the QoS level
  #
  # For example:
  #   packet.topics = 'a/b'
  #   packet.topics = ['a/b', 'c/d']
  #   packet.topics = [['a/b',0], ['c/d',1]]
  #   packet.topics = {'a/b' => 0, 'c/d' => 1}
  #
  def topics=(value)
    # Get input into a consistent state
    input = value.is_a?(Array) ? value.flatten : [value]

    @topics = []
    until input.empty?
      item = input.shift
      if item.is_a?(Hash)
        # Convert hash into an ordered array of arrays
        @topics += item.sort
      elsif item.is_a?(String)
        # Peek at the next item in the array, and remove it if it is an integer
        if input.first.is_a?(Integer)
          qos = input.shift
          @topics << [item, qos]
        else
          @topics << [item, 0]
        end
      else
        # Meh?
        raise "Invalid topics input: #{value.inspect}"
      end
    end
    @topics
  end

  # Get serialisation of packet's body
  def encode_body
    raise 'no topics given when serialising packet' if @topics.empty?
    body = encode_short(@id)
    topics.each do |item|
      body += encode_string(item[0])
      body += encode_bytes(item[1])
    end
    body
  end

  # Parse the body (variable header and payload) of a packet
  def parse_body(buffer)
    super(buffer)
    @id = shift_short(buffer)
    @topics = []
    while buffer.bytesize > 0
      topic_name = shift_string(buffer)
      topic_qos = shift_byte(buffer)
      @topics << [topic_name, topic_qos]
    end
  end

  # Check that fixed header flags are valid for this packet type
  # @private
  def validate_flags
    return if @flags == [false, true, false, false]
    raise ParseException, 'Invalid flags in SUBSCRIBE packet header'
  end

  # Returns a human readable string, summarising the properties of the packet
  def inspect
    _str = "\#<#{self.class}: 0x%2.2X, %s>" % [
      id,
      topics.map { |t| "'#{t[0]}':#{t[1]}" }.join(', ')
    ]
  end
end
