require 'spec_helper'

describe Solid::LiquidExtensions::UnlessTag do
  it_should_behave_like 'a tag highjacker'

  context 'when Liquid::Unless is replaced' do

    before :each do
      described_class.load!
    end

    after :each do
      described_class.unload!
    end

    it 'should allow complex expression inside an unless tag' do
      template = Solid::Template.parse(%(
        {% unless foo.include?('bar') %}
          Hello !
        {% endunless %}
      ))
      output = template.render('foo' => ' spam ').strip
      output.should be == 'Hello !'
    end

    it 'should still accept an else tag' do
      template = Solid::Template.parse(%(
        {% unless foo.include?('bar') %}
          Hello !
        {% else %}
          Failed
        {% endunless %}
      ))
      output = template.render('foo' => ' bar ').strip
      output.should be == 'Failed'
    end

    it 'should still accept some elsif tags' do
      template = Solid::Template.parse(%(
        {% unless foo.include?('spam') %}
          Hello !
        {% elsif foo.include?('spam') %}
          World !
        {% else %}
          Failed
        {% endunless %}
      ))
      output = template.render('foo' => ' spam ').strip
      output.should be == 'World !'
    end

  end

end
