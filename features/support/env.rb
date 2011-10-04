require File.expand_path('../../spec/spec_helper', File.dirname(__FILE__))

require 'aruba/cucumber'

Before do
  ENV['BUNDLE_GEMFILE'] = 'Gemfile'
  @aruba_timeout_seconds = 60
end 
