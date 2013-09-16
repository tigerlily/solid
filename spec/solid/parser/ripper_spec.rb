require 'spec_helper'

ripper_support = true
begin
  require 'ripper'
rescue LoadError
  ripper_support = false
end

describe Solid::Parser::Ripper do

  it_should_behave_like 'a solid parser'

end if ripper_support
