require 'spec_helper'

describe Solid::LiquidExtensions::ForTag do
  it_should_behave_like 'a tag highjacker'

  context 'when Liquid::For is replaced' do

    before :each do
      described_class.load!
    end

    after :each do
      described_class.unload!
    end

    it 'should allow complex expression inside a for tag' do
      template = Solid::Template.parse(%(
        {% for foo in foos.concat(foos.reverse).flatten %}
          {{ foo }}
        {% endfor %}
      ))
      output = template.render('foos' => [1, 2, 3]).gsub(/[^\d]/, '')
      output.should be == '123321'
    end

    it 'should still provide the "forloop" object' do
      template = Solid::Template.parse(%(
        {% for foo in foos %}{{ forloop.index0 }}/{{ forloop.length }}|{% endfor %}
      ))
      output = template.render('foos' => [1, 2, 3]).strip
      output.should be == "0/3|1/3|2/3|"
    end

  end

end
