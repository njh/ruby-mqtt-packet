require_relative 'lib/mqtt/packet/version'

Gem::Specification.new do |gem|
  gem.name        = 'mqtt-packet'
  gem.version     = MQTT::Packet::VERSION
  gem.author      = 'Nicholas J Humfrey'
  gem.email       = 'njh@aelius.com'
  gem.homepage    = 'https://github.com/njh/ruby-mqtt-packet'
  gem.summary     = 'MQTT and MQTT-SN packet parser and generator'
  gem.description = 'Pure Ruby gem that parses and serialises MQTT and MQTT-SN binary packets.'
  gem.license     = 'MIT'

  # The oldest version of Ruby that the automated tests run against
  gem.required_ruby_version = '>= 2.3'

  gem.files         = %w(README.md LICENSE.md NEWS.md) + Dir.glob('lib/**/*.rb')
  gem.require_paths = %w(lib)

  # Development dependencies are in the Gemfile
end
