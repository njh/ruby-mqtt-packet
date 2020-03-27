# encoding: BINARY

module MQTT
  module SN
    # Class representing a MQTT::SN Packet
    # Performs binary encoding and decoding of headers
    class Packet
      attr_accessor :duplicate     # Duplicate delivery flag
      attr_accessor :qos           # Quality of Service level
      attr_accessor :retain        # Retain flag
      attr_accessor :request_will  # Request that gateway prompts for Will
      attr_accessor :clean_session # When true, subscriptions are deleted after disconnect
      attr_accessor :topic_id_type # One of :normal, :predefined or :short

      DEFAULTS = {}

      # Parse buffer into new packet object
      def self.parse(buffer)
        # Parse the fixed header (length and type)
        length, type_id, body = buffer.unpack('CCa*')
        length, type_id, body = buffer.unpack('xnCa*') if length == 1

        # Double-check the length
        if buffer.length != length
          raise ParseException, 'Length of packet is not the same as the length header'
        end

        packet_class = PACKET_TYPES[type_id]
        if packet_class.nil?
          raise ParseException, "Invalid packet type identifier: #{type_id}"
        end

        # Create a new packet object
        packet = packet_class.new
        packet.parse_body(body)

        packet
      end

      # Create a new empty packet
      def initialize(args = {})
        update_attributes(self.class::DEFAULTS.merge(args))
      end

      def update_attributes(attr = {})
        attr.each_pair do |k, v|
          send("#{k}=", v)
        end
      end

      # Get the identifer for this packet type
      def type_id
        PACKET_TYPES.each_pair do |key, value|
          return key if self.class == value
        end
        raise "Invalid packet type: #{self.class}"
      end

      # Serialise the packet
      def to_s
        # Get the packet's variable header and payload
        body = encode_body

        # Build up the body length field bytes
        body_length = body.length
        raise 'MQTT-SN Packet is too big, maximum packet body size is 65531' if body_length > 65_531

        if body_length > 253
          [0x01, body_length + 4, type_id].pack('CnC') + body
        else
          [body_length + 2, type_id].pack('CC') + body
        end
      end

      def parse_body(buffer); end

      protected

      def parse_flags(flags)
        self.duplicate = ((flags & 0x80) >> 7) == 0x01
        self.qos = (flags & 0x60) >> 5
        self.qos = -1 if qos == 3
        self.retain = ((flags & 0x10) >> 4) == 0x01
        self.request_will = ((flags & 0x08) >> 3) == 0x01
        self.clean_session = ((flags & 0x04) >> 2) == 0x01

        self.topic_id_type =
          case (flags & 0x03)
          when 0x0
            :normal
          when 0x1
            :predefined
          when 0x2
            :short
          end
      end

      # Get serialisation of packet's body (variable header and payload)
      def encode_body
        '' # No body by default
      end

      def encode_flags
        flags = 0x00
        flags += 0x80 if duplicate
        case qos
        when -1
          flags += 0x60
        when 1
          flags += 0x20
        when 2
          flags += 0x40
        end
        flags += 0x10 if retain
        flags += 0x08 if request_will
        flags += 0x04 if clean_session
        case topic_id_type
        when :normal
          flags += 0x0
        when :predefined
          flags += 0x1
        when :short
          flags += 0x2
        end
        flags
      end

      def encode_topic_id
        if topic_id_type == :short
          unless topic_id.is_a?(String)
            raise "topic_id must be an String for type #{topic_id_type}"
          end
          (topic_id[0].ord << 8) + topic_id[1].ord
        else
          unless topic_id.is_a?(Integer)
            raise "topic_id must be an Integer for type #{topic_id_type}"
          end
          topic_id
        end
      end

      def parse_topic_id(topic_id)
        if topic_id_type == :short
          int = topic_id.to_i
          self.topic_id = [(int >> 8) & 0xFF, int & 0xFF].pack('CC')
        else
          self.topic_id = topic_id
        end
      end

      # Used where a field can either be a Topic Id or a Topic Name
      # (the Subscribe and Unsubscribe packet types)
      def encode_topic
        case topic_id_type
        when :normal
          topic_name
        when :short
          if topic_name.nil?
            topic_id
          else
            topic_name
          end
        when :predefined
          [topic_id].pack('n')
        end
      end

      # Used where a field can either be a Topic Id or a Topic Name
      # (the Subscribe and Unsubscribe packet types)
      def parse_topic(topic)
        case topic_id_type
        when :normal
          self.topic_name = topic
        when :short
          self.topic_name = topic
          self.topic_id = topic
        when :predefined
          self.topic_id = topic.unpack('n').first
        end
      end

      class ParseException < ::Exception
      end

      require 'mqtt/sn/packet/advertise'
      require 'mqtt/sn/packet/connack'
      require 'mqtt/sn/packet/connect'
      require 'mqtt/sn/packet/disconnect'
      require 'mqtt/sn/packet/gwinfo'
      require 'mqtt/sn/packet/pingreq'
      require 'mqtt/sn/packet/pingresp'
      require 'mqtt/sn/packet/puback'
      require 'mqtt/sn/packet/pubcomp'
      require 'mqtt/sn/packet/publish'
      require 'mqtt/sn/packet/pubrec'
      require 'mqtt/sn/packet/pubrel'
      require 'mqtt/sn/packet/regack'
      require 'mqtt/sn/packet/register'
      require 'mqtt/sn/packet/searchgw'
      require 'mqtt/sn/packet/suback'
      require 'mqtt/sn/packet/subscribe'
      require 'mqtt/sn/packet/unsuback'
      require 'mqtt/sn/packet/unsubscribe'
      require 'mqtt/sn/packet/willmsg'
      require 'mqtt/sn/packet/willmsgreq'
      require 'mqtt/sn/packet/willmsgresp'
      require 'mqtt/sn/packet/willmsgupd'
      require 'mqtt/sn/packet/willtopic'
      require 'mqtt/sn/packet/willtopicreq'
      require 'mqtt/sn/packet/willtopicresp'
      require 'mqtt/sn/packet/willtopicupd'
    end

    # An enumeration of the MQTT-SN packet types
    PACKET_TYPES = {
      0x00 => MQTT::SN::Packet::Advertise,
      0x01 => MQTT::SN::Packet::Searchgw,
      0x02 => MQTT::SN::Packet::Gwinfo,
      0x04 => MQTT::SN::Packet::Connect,
      0x05 => MQTT::SN::Packet::Connack,
      0x06 => MQTT::SN::Packet::Willtopicreq,
      0x07 => MQTT::SN::Packet::Willtopic,
      0x08 => MQTT::SN::Packet::Willmsgreq,
      0x09 => MQTT::SN::Packet::Willmsg,
      0x0a => MQTT::SN::Packet::Register,
      0x0b => MQTT::SN::Packet::Regack,
      0x0c => MQTT::SN::Packet::Publish,
      0x0d => MQTT::SN::Packet::Puback,
      0x0e => MQTT::SN::Packet::Pubcomp,
      0x0f => MQTT::SN::Packet::Pubrec,
      0x10 => MQTT::SN::Packet::Pubrel,
      0x12 => MQTT::SN::Packet::Subscribe,
      0x13 => MQTT::SN::Packet::Suback,
      0x14 => MQTT::SN::Packet::Unsubscribe,
      0x15 => MQTT::SN::Packet::Unsuback,
      0x16 => MQTT::SN::Packet::Pingreq,
      0x17 => MQTT::SN::Packet::Pingresp,
      0x18 => MQTT::SN::Packet::Disconnect,
      0x1a => MQTT::SN::Packet::Willtopicupd,
      0x1b => MQTT::SN::Packet::Willtopicresp,
      0x1c => MQTT::SN::Packet::Willmsgupd,
      0x1d => MQTT::SN::Packet::Willmsgresp
    }
  end
end
