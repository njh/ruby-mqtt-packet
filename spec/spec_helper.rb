# SimpleCov must be started before each spec requires the library code
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end
