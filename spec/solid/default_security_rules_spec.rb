require 'spec_helper'

describe Solid, 'default security rules' do

  shared_examples_for 'a ruby object' do
    it_should_safely_respond_to :nil?, :==, :!=, :!
  end

  shared_examples_for 'an enumerable' do
    it_should_safely_respond_to :sort, :length, :size
  end

  shared_examples_for 'a comparable' do
    it_should_safely_respond_to :<, :<=, :==, :>, :>=, :between?
  end

  shared_examples_for 'a numeric' do
    it_should_behave_like 'a comparable'
    it_should_safely_respond_to :%, :*, :**, :+, :-, :-@, :/, :<=>, :===, :to_s, :abs
  end

  shared_examples_for 'a fixnum' do
    it_should_behave_like 'a numeric'
    it_should_safely_respond_to :div, :divmod, :even?, :odd?, :to_f
  end

  describe 'Basic object instance' do

    let(:basic_class) { Class.new(Object) }

    subject { basic_class.new }

    it_should_behave_like 'a ruby object'

  end

  describe 'Array instances' do

    subject { [] }

    it_should_behave_like 'a ruby object', 'an enumerable'
    it_should_safely_respond_to :[], :[]=, :first, :last, :join, :reverse, :uniq, :include?, :empty?
  end

  describe 'Hash instances' do

    subject { {} }

    it_should_behave_like 'a ruby object', 'an enumerable'
    it_should_safely_respond_to :[], :[]=, :has_key?, :has_value?, :empty?

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
