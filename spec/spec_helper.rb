$:.unshift(File.join(File.dirname(__FILE__),'..','lib'))

require 'bundler'

# Only load the development dependencies here, so that SimpleCov is
# started before each spec requires the library code
Bundler.require(:development)

SimpleCov.start do
  add_filter '/spec/'
end
