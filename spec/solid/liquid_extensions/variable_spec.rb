require 'spec_helper'

describe Solid::LiquidExtensions::Variable do
  it_should_behave_like 'a class highjacker'

  context 'real world example' do

    before :each do
      described_class.load!
    end

    after :each do
      described_class.unload!
    end

    let(:template) { template = Solid::Template.parse('{{ foo.include?("bar") | upcase }}') }

    it 'should allow method call with arguments in variables brackets' do
      template.render('foo' => 'egg bar spam').should be == 'TRUE'
      template.render('foo' => '').should be == 'FALSE'
    end

  end

end
