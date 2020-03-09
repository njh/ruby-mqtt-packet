#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mqtt/packet/version"

Gem::Specification.new do |gem|
  gem.name        = 'mqtt-packet'
  gem.version     = MQTT::Packet::VERSION
  gem.author      = 'Nicholas J Humfrey'
  gem.email       = 'njh@aelius.com'
  gem.homepage    = 'http://github.com/njh/ruby-mqtt-packet'
  gem.summary     = 'MQTT and MQTT-SN packet parser and generator'
  gem.description = 'Ruby gem that parses and serialises MQTT and MQTT-SN binary packets'
  gem.license     = 'MIT' if gem.respond_to?(:license=)

  gem.files         = %w(README.md LICENSE.md NEWS.md) + Dir.glob('lib/**/*.rb')
  gem.test_files    = Dir.glob('spec/*_spec.rb')
  gem.executables   = %w()
  gem.require_paths = %w(lib)

  gem.add_development_dependency 'bundler',  '>= 1.11.2'
  gem.add_development_dependency 'rake',     '>= 10.2.2'
  gem.add_development_dependency 'yard',     '>= 0.9.11'
  gem.add_development_dependency 'rspec',    '>= 3.5.0'
  gem.add_development_dependency 'simplecov','>= 0.9.2'
  gem.add_development_dependency 'rubocop',  '~> 0.48.0'
end
