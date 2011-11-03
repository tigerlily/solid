require 'rspec'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'solid'))

RSpec.configure do |c|
  c.mock_with :rspec
end