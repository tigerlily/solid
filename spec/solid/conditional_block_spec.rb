require 'spec_helper'

class IfPresent < Solid::ConditionalBlock

  def display(string)
    yield(!string.strip.empty?)
  end

end

describe Solid::ConditionalBlock do

  it_behaves_like "a Solid element"

  describe '#display' do

    let(:tokens) { ["present", "{% else %}", "blank", "{% endifpresent %}"] }

    subject{ IfPresent.new('ifpresent', 'mystring', tokens) }

    it 'yielding true should render the main block' do
      context = Liquid::Context.new('mystring' => 'blah')
      subject.render(context).should be == 'present'
    end

    it 'yielding false should render the `else` block' do
      context = Liquid::Context.new('mystring' => '')
      subject.render(context).should be == 'blank'
    end

    it 'yielding false without a `else` block does not render anything' do
      context = Liquid::Context.new('mystring' => '')
      subject = IfPresent.new('ifpresent', 'mystring', ['present', '{% endifpresent %}'])
      subject.render(context).should be_nil
    end

  end

end
