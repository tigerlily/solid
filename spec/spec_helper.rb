require 'rspec'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'solid'))

RSpec.configure do |c|
  c.mock_with :rspec
end

Dir[File.join(File.dirname(__FILE__), '/**/*_examples.rb'), File.join(File.dirname(__FILE__), '/**/*_matchers.rb')].each{ |f| require f }
