require 'spec_helper'

describe Solid, 'default security rules' do

  describe 'Hash instances' do

    subject { {} }

    it { should safely_respond_to :sort }

  end

  describe 'Kernel instances' do

    subject { Object.new }

    it { should safely_respond_to :nil? }

  end

  describe 'Basic object instance' do

    let(:basic_class) { Class.new(Object) }

    subject { basic_class.new }

    it { should safely_respond_to :! }

    it { should safely_respond_to :!= }

    it { should safely_respond_to :== }

  end

  shared_examples_for 'a numeric' do

    [:%, :*, :**, :+, :-, :-@, :/, :<, :<=, :<=>, :==, :===, :>, :>=, :to_s, :abs].each do |method|
      it { should safely_respond_to method }
    end

  end

  shared_examples_for 'a fixnum' do
    it_should_behave_like 'a numeric'

    [:div, :divmod, :even?, :odd?, :to_f].each do |method|
      it { should safely_respond_to method }
    end
    
  end

  describe 'Bignum instances' do

    subject { 2 ** 123 }

    it { should be_a Bignum }

    it_should_behave_like 'a fixnum'

  end

  describe 'Integer instances' do

    subject { 4 }

    it { should be_a Integer }

    it_should_behave_like 'a fixnum'

  end

  describe 'Float instances' do

    subject { 4.2 }

    it { should be_a Float }

    it_should_behave_like 'a numeric'
  end

end
