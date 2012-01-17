require 'spec_helper'

describe Solid::LiquidExtensions::IfTag do
  it_should_behave_like 'a tag highjacker'

  context 'when Liquid::If is replaced' do

    before :each do
      described_class.load!
    end

    after :each do
      described_class.unload!
    end

    it 'should allow complex expression inside an if tag' do
      template = Solid::Template.parse(%(
        {% if foo.include?('bar') %}
          Hello !
        {% endif %}
      ))
      output = template.render('foo' => ' bar ').strip
      output.should be == 'Hello !'
    end

    it 'should render nothing if the predicate return false' do
      template = Solid::Template.parse(%(
        {% if foo.include?('bar') %}
          Hello !
        {% endif %}
      ))
      output = template.render('foo' => ' plop ').strip
      output.should be == ''
    end

    it 'should still accept an else tag' do
      template = Solid::Template.parse(%(
        {% if foo.include?('bar') %}
          Hello !
        {% else %}
          Failed
        {% endif %}
      ))
      output = template.render('foo' => ' spam ').strip
      output.should be == 'Failed'
    end

    it 'should still accept some elsif tags' do
      template = Solid::Template.parse(%(
        {% if foo.include?('bar') %}
          Hello !
        {% elsif foo.include?('spam') %}
          World !
        {% else %}
          Failed
        {% endif %}
      ))
      output = template.render('foo' => ' spam ').strip
      output.should be == 'World !'
    end

  end

end
