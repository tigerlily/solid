require 'spec_helper'

describe Solid::Argument do

  describe '#unterminated?' do

    context 'for string arguments' do

      it 'should return nil if it is terminated' do
        arg = Solid::Argument.new('"Hello"')
        arg.should_not be_unterminated
      end

      it 'should return missing terminator (") if it is unterminated' do
        arg = Solid::Argument.new('"Hello')
        arg.should be_unterminated
        arg.unterminated?.should be == '"'
      end

      it 'should return missing terminator (\') if it is unterminated' do
        arg = Solid::Argument.new("'Hello")
        arg.should be_unterminated
        arg.unterminated?.should be == "'"
      end

    end

    context 'for named argument of value String' do

      it 'should return nil if it is terminated' do
        arg = Solid::Argument.new('foo:"Hello"')
        arg.should_not be_unterminated
      end

      it 'should return missing terminator (") if it is unterminated' do
        arg = Solid::Argument.new('foo: "Hello')
        arg.should be_unterminated
        arg.unterminated?.should be == '"'
      end

      it 'should return missing terminator (\') if it is unterminated' do
        arg = Solid::Argument.new("foo:'Hello")
        arg.should be_unterminated
        arg.unterminated?.should be == "'"
      end

    end

  end

end
