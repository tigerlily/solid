require 'spec_helper'

describe Solid::LiquidExtensions::AssignTag do
  it_should_behave_like 'a tag highjacker'

  context 'when Liquid::Assign is replaced' do

    before :each do
      described_class.load!
    end

    after :each do
      described_class.unload!
    end

    it 'should allow complex expression inside an assign tag' do
      template = Solid::Template.parse(%(
        {% assign included = foo.include?('bar') %}
        {{ included }}
      ))
      output = template.render('foo' => ' bar ').strip
      output.should be == 'true'
    end

  end

end
