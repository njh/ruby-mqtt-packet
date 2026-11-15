[![Build Status](https://github.com/njh/ruby-mqtt-packet/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/njh/ruby-mqtt-packet/actions/workflows/build.yml?query=branch%3Amain)

ruby-mqtt-packet
================

Pure Ruby gem for parsing and serialising [MQTT] and [MQTT-SN] binary packets.

[MQTT] is a lightweight protocol for publish/subscribe messaging, and
[MQTT-SN] is a variant of it designed for sensor networks.
This gem only deals with the packets; you can use it to build your own
clients and servers on top of whatever transport you like.


Relationship to the mqtt gem
----------------------------

The packet code was extracted from version 0.7.0 of the [mqtt gem], which also
includes an MQTT client. If you just want to connect to an MQTT server, use that gem instead.


Installation
------------

You may get the latest stable version from [Rubygems]:

    $ gem install mqtt-packet

Alternatively, to use a development snapshot from GitHub using [Bundler], add this to your `Gemfile`:

~~~ ruby
gem 'mqtt-packet', :git => 'https://github.com/njh/ruby-mqtt-packet.git'
~~~


Supported Ruby Versions
-----------------------

The automated tests run against CRuby 2.3 through to 4.0, and the latest version of JRuby.
See [build.yml](.github/workflows/build.yml) for the exact list.


Quick Start
-----------

~~~ ruby
require 'mqtt/packet'

# Parse a string containing a binary PUBLISH packet into an object
packet = MQTT::Packet.parse("\x30\x0b\x00\x04testhello")
packet.class    # => MQTT::Packet::Publish
packet.topic    # => "test"
packet.payload  # => "hello"

# Read a single packet from a socket or other IO handle
packet = MQTT::Packet.read(socket)

# Write a PUBACK packet to an IO handle
socket << MQTT::Packet::Puback.new(:id => 20)

# Serialise a packet into a binary string
binary = MQTT::Packet::Publish.new(:topic => 'test', :payload => 'hello').to_s
~~~

If a packet is malformed, an `MQTT::Packet::ParseException` is raised.


MQTT-SN packets work in the same way, using the `MQTT::SN::Packet` classes:

~~~ ruby
require 'mqtt/sn/packet'
require 'socket'

# Write an MQTT-SN Publish packet with QoS -1 to a UDP socket
socket = UDPSocket.new
socket.connect('localhost', 1883)
socket << MQTT::SN::Packet::Publish.new(
  :topic_id => 'TT',
  :topic_id_type => :short,
  :data => "The time is: #{Time.now}",
  :qos => -1
)
socket.close
~~~

If an MQTT-SN packet is malformed, an `MQTT::SN::Packet::ParseException` is raised.


Limitations
-----------

 * Only versions v3.1 and v3.1.1 of the MQTT protocol are currently supported


Development
-----------

After checking out the repository, install the dependencies, then run the tests and [RuboCop] checks:

    $ bundle install
    $ bundle exec rake

To generate the API documentation into the `doc` directory, run `bundle exec rake doc:yard`.


Resources
---------

* API Documentation: https://rubydoc.info/gems/mqtt-packet
* Protocol Specification v3.1.1: https://docs.oasis-open.org/mqtt/mqtt/v3.1.1/mqtt-v3.1.1.html
* Protocol Specification v3.1: https://public.dhe.ibm.com/software/dw/webservices/ws-mqtt/mqtt-v3r1.html
* MQTT-SN Protocol Specification v1.2: https://www.oasis-open.org/committees/download.php/66091/MQTT-SN_spec_v1.2.pdf
* MQTT Homepage: https://mqtt.org/
* GitHub Project: https://github.com/njh/ruby-mqtt-packet


License
-------

The mqtt-packet ruby gem is licensed under the terms of the MIT license.
See the file LICENSE.md for details.


Contact
-------

* Author:    Nicholas J Humfrey
* Home Page: https://njh.me/



[MQTT]:           https://mqtt.org/
[MQTT-SN]:        https://www.oasis-open.org/committees/download.php/66091/MQTT-SN_spec_v1.2.pdf
[mqtt gem]:       https://www.github.com/njh/ruby-mqtt
[Rubygems]:       https://rubygems.org/
[Bundler]:        https://bundler.io/
[RuboCop]:        https://rubocop.org/
