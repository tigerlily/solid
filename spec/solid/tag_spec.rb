require 'spec_helper'

class DummyTag < Solid::Tag

  def display(*args)
    args.inspect
  end

end

describe Solid::Tag do

  it_behaves_like "a Solid element"

  subject{ DummyTag.new('dummy', '1, "foo", myvar, myopts: false', 'token') }

  it 'should works' do
    subject.render('myvar' => 'bar').should be == '[1, "foo", "bar", {:myopts=>false}]'
  end

  it 'should send all parsed arguments do #display' do
    subject.should_receive(:display).with(1, 'foo', 'bar', :myopts => false).and_return('result')
    subject.render('myvar' => 'bar').should be == 'result'
  end

end