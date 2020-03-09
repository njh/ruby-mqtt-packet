[![Build Status](https://travis-ci.org/njh/ruby-mqtt-packet.svg)](https://travis-ci.org/njh/ruby-mqtt-packet)

ruby-mqtt-packet
================

[MQTT] is a lightweight protocol for publish/subscribe messaging.



Installation
------------

You may get the latest stable version from [Rubygems]:

    $ gem install mqtt-packet

Alternatively, to use a development snapshot from GitHub using [Bundler]:

    gem 'mqtt', :git => 'https://github.com/njh/ruby-mqtt-packet.git'


Quick Start
-----------

The parsing and serialising of MQTT and MQTT-SN packets is a separate lower-level API.
You can use it to build your own clients and servers, without using any of the rest of the
code in this gem.

~~~ ruby
# Parse a string containing a binary packet into an object
packet_obj = MQTT::Packet.parse(binary_packet)
    
# Write a PUBACK packet to an IO handle
ios << MQTT::Packet::Puback(:id => 20)
    
# Write an MQTT-SN Publish packet with QoS -1 to a UDP socket
socket = UDPSocket.new
socket.connect('localhost', MQTT::SN::DEFAULT_PORT)
socket << MQTT::SN::Packet::Publish.new(
  :topic_id => 'TT',
  :topic_id_type => :short,
  :data => "The time is: #{Time.now}",
  :qos => -1
)
socket.close
~~~


Limitations
-----------

 * Only version v3.1 and v3.1.1 versions of the protocol are currently supported


Resources
---------

* API Documentation: http://rubydoc.info/gems/mqtt-packet
* Protocol Specification v3.1.1: http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/mqtt-v3.1.1.html
* Protocol Specification v3.1: http://public.dhe.ibm.com/software/dw/webservices/ws-mqtt/mqtt-v3r1.html
* MQTT-SN Protocol Specification v1.2: http://mqtt.org/new/wp-content/uploads/2009/06/MQTT-SN_spec_v1.2.pdf
* MQTT Homepage: http://www.mqtt.org/


License
-------

The mqtt ruby gem is licensed under the terms of the MIT license.
See the file LICENSE for details.


Contact
-------

* Author:    Nicholas J Humfrey
* Email:     njh@aelius.com
* Twitter:   [@njh]
* Home Page: http://www.aelius.com/njh/



[@njh]:           http://twitter.com/njh
[MQTT]:           http://www.mqtt.org/
[MQTT-SN]:        http://mqtt.org/2013/12/mqtt-for-sensor-networks-mqtt-sn
[Rubygems]:       http://rubygems.org/
[Bundler]:        http://bundler.io/
