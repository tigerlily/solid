require 'spec_helper'
require 'active_support/core_ext'

describe Solid, 'default security rules' do

  shared_examples_for 'a ruby object' do
    it_should_safely_respond_to :nil?, :==, :!=, :!, :!~, :blank?, :present?, :in?, :to_json
    it_should_not_safely_respond_to :const_get, :const_set,
      :instance_variable_get, :instance_variable_set, :instance_variable_defined?,
      :send, :__send__, :public_send,
      :__id__, :object_id,
      :class, :singleton_class, :trust, :taint, :untaint, :untrust,
      :clone, :dup, :initialize_dup, :initialize_clone, :freeze,
      :methods, :singleton_methods, :protected_methods, :private_methods,
      :method, :public_method, :define_singleton_method, :extend,
      :eval, :instance_eval, :instance_exec, :exec, :`, :system, :test,
      :global_variables, :local_variables,
      :gets, :readline, :readlines, :sleep,
      :at_exit!, :exit, :fork, :spawn, :trap, :exit!, :syscall
  end

  shared_examples_for 'a ruby module' do
    it_should_behave_like 'a ruby object'
    it_should_not_safely_respond_to :ancestors
  end

  shared_examples_for 'a ruby class' do
    it_should_behave_like 'a ruby module'
    it_should_not_safely_respond_to :new, :allocate, :superclass
  end

  shared_examples_for 'a boolean' do
    it_should_behave_like 'a ruby object'
    it_should_safely_respond_to :false?, :true?
  end

  shared_examples_for 'an enumerable' do
    it_should_safely_respond_to :sort, :length, :size
  end

  shared_examples_for 'a comparable' do
    it_should_safely_respond_to :<, :<=, :==, :>, :>=, :between?
  end

  shared_examples_for 'a numeric' do
    it_should_behave_like 'a ruby object', 'a comparable'
    it_should_safely_respond_to :%, :*, :**, :+, :-, :-@, :/, :<=>, :===, :to_s, :abs,
      :second, :seconds, :minute, :minutes, :hour, :hours, :day, :days, :week, :weeks,
      :bytes, :kilobytes, :megabytes, :gigabytes, :terabytes, :petabytes, :exabytes
  end

  shared_examples_for 'an integer' do
    it_should_behave_like 'a numeric'
    it_should_safely_respond_to :div, :divmod, :even?, :odd?, :to_f,
      :month, :months, :year, :years
  end

  describe 'nil' do
    subject { nil }

    it_should_behave_like 'a ruby object'
  end

  describe true do
    subject { true }

    it_should_behave_like 'a ruby object'
  end

  describe false do
    subject { false }

    it_should_behave_like 'a ruby object'
  end

  describe 'Basic object instance' do
    let(:basic_class) { Class.new(Object) }
    subject { basic_class.new }

    it_should_behave_like 'a ruby object'
  end

  describe 'Array instances' do
    subject { [] }

    it_should_behave_like 'a ruby object', 'an enumerable'
    it_should_safely_respond_to :[], :[]=, :first, :last, :join, :reverse, :uniq, :include?, :empty?,
      :to_sentence, :in_groups_of, :in_groups
  end

  describe 'Array class' do
    subject { Array }

    it_should_behave_like 'a ruby class'
    it_should_safely_respond_to :wrap
  end

  describe 'Hash instances' do
    subject { {} }

    it_should_behave_like 'a ruby object', 'an enumerable'
    it_should_safely_respond_to :[], :[]=, :has_key?, :has_value?, :empty?, :except, :slice
  end

  describe 'Range instances' do
    subject { 1..10 }

    it_should_behave_like 'a ruby object', 'an enumerable'
    it_should_safely_respond_to :first, :last, :begin, :end, :max, :min, :cover?, :include?, :member?
  end

  describe 'Regexp instances' do
    subject { /bb|[^b]{2}/ }

    it_should_behave_like 'a ruby object'
    it_should_safely_respond_to :==, :===, :=~, :match
  end

  describe 'Bignum instances' do
    subject { 2 ** 123 }

    it { should be_a Bignum }
    it_should_behave_like 'an integer'
  end

  describe 'Fixnum instances' do
    subject { 4 }

    it_should_behave_like 'an integer'
    it_should_safely_respond_to :multiple_of?
  end

  describe 'Float instances' do
    subject { 4.2 }

    it_should_behave_like 'a numeric'
  end

  describe 'Time class' do
    subject { Time }

    it_should_behave_like 'a ruby class'
    it_should_safely_respond_to :at, :now
  end

  describe 'Time instances' do
    subject { Time.now }

    it_should_safely_respond_to :to_i, :to_f, :<=>,
      :localtime, :gmtime, :utc, :getlocal, :getgm, :getutc,
      :ctime, :asctime, :to_s, :inspect, :to_a, :+, :-, :round,
      :sec, :min, :hour, :mday, :day, :mon, :month, :year, :wday, :yday,
      :isdst, :dst?, :zone, :gmtoff, :gmt_offset, :utc_offset, :utc?, :gmt?,
      :sunday?, :monday?, :tuesday?, :wednesday?, :thursday?, :friday?, :saturday?,
      :tv_sec, :tv_usec, :usec, :tv_nsec, :nsec, :subsec, :strftime,
      :to_time, :to_date, :to_datetime
  end

  describe 'String instances' do
    subject { 'string' }

    it_should_behave_like 'a ruby object', 'a comparable', 'an enumerable'
    it_should_safely_respond_to :gsub, :strip, :chop, :chomp, :start_with?, :end_with?,
      :[], :length, :size, :empty?, :=~, :split, :upcase, :downcase, :capitalize, :squeeze, :tr,
      :exclude?, :truncate
  end

  describe 'Module instances' do
    subject { Module.new }

    it_should_behave_like 'a ruby module'
  end

  describe 'Class instances' do
    subject { Class.new }

    it_should_behave_like 'a ruby class'
  end

end
