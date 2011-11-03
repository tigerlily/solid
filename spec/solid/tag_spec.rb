require 'spec_helper'

class DummyTag < Solid::Tag

  def display(*args)
    args.map(&:to_s).join
  end

end

describe Solid::Tag do

  subject{ DummyTag.new('dummy', '1, "foo", myvar, myopts: false', 'token') }

  it 'should works' do
    subject.render('myvar' => 'bar').should be == '1foobar{:myopts=>false}'
  end

  it 'should send all parsed arguments do #display' do
    subject.should_receive(:display).with(1, 'foo', 'bar', myopts: false).and_return('result')
    subject.render('myvar' => 'bar').should be == 'result'
  end

  describe '.name' do

    it 'should register tag to Liquid with given name' do
      Liquid::Template.should_receive(:register_tag).with('dummy', DummyTag)
      DummyTag.name 'dummy'
    end

    it 'should return previously given name' do
      Liquid::Template.stub(:register_tag)
      DummyTag.name 'dummy'
      DummyTag.name.should be == 'dummy'
    end

  end

end