# SimpleCov must be started before each spec requires the library code
require 'simplecov'

# The test_frameworks profile excludes the spec directory from coverage
SimpleCov.start 'test_frameworks'
