require 'spec_helper'

class DummyBlock < Solid::Block

  def display(condition)
    if condition
      yield
    else
      'not_yielded'
    end
  end

end

describe Solid::Block do

  it_behaves_like "a Solid element"

  describe '#display' do

    let(:tokens) { ["dummy", "{% enddummy %}", "outside"] }

    subject{ DummyBlock.new('dummy', 'yield', tokens) }

    it 'yielding should render the block content' do
      subject.render('yield' => true).should be == 'dummy'
    end

    it 'should only render until the {% endblock %} tag' do
      subject.render('yield' => true).should_not include('outside')
    end

    it 'should not render its content if it do not yield' do
      subject.render('yield' => false).should_not include('dummy')
    end

  end

end
