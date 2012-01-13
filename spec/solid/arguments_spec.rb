require 'spec_helper'

describe Solid::Arguments do

  class DummyDrop < Liquid::Drop

    def before_method(name)
      "dummy #{name}"
    end

  end

  def parse(string, context={})
    Solid::Arguments.parse(string).interpolate(Liquid::Context.new(context))
  end

  context 'with no arguments' do

    it "parses as an empty array" do
      parse('').should be == []
    end

  end

  context 'with a single argument' do

    context 'of type string' do

      it 'can parse a constant' do
        parse("FooBar", {'FooBar' => 42}).should be == [42]
      end

      it 'can parse a simple string (between simple quotes)' do
        parse("'foobar'").should be == ['foobar']
      end

      it 'can parse a simple string (between double quotes)' do
        parse('"foobar"').should be == ['foobar']
      end

      it 'should not consider this string as a context var' do
        parse('"foobar"', {'foobar' => 'plop'}).should_not == ['plop']
      end

      it 'should not be disturbed by a string containing a comma' do
        parse(%{"foo,bar", 'egg,spam'}).should be == ['foo,bar', 'egg,spam']
      end

      it 'should not be disturbed by a string containing a simple quote' do
        parse('"foo\'bar"').should be == ["foo'bar"]
      end

      it 'should not be disturbed by a string containing a double quote' do
        parse("'foo\"bar'").should be == ['foo"bar']
      end

      it 'should work for a string containing interpolation' do
        pending('not yet implemented')
        parse('"1#{foo}3"', {'foo' => 2}).should be == ['123']
      end

    end

    context 'of type integer' do

      it 'should work' do
        parse('42').should be == [42]
      end

    end

    context 'of type float' do

      it 'should work' do
        parse('4.2').should be == [4.2]
      end

    end

    context 'of type boolean' do

      it 'should work with `true`' do
        parse('true').should be == [true]
      end

      it 'should work with `false`' do
        parse('false').should be == [false]
      end

    end

    context 'of type Regexp' do

      it 'should work for simple cases' do
        parse('/bb|[^b]{2}/').should be == [/bb|[^b]{2}/]
      end

      it 'should work for a regexp containing interpolation' do
        pending('not yet implemented')
        parse('/#{mystring}|[^b]{2}/', {'mystring' => 'bb'}).should be == [/bb|[^b]{2}/]
      end

    end

    context 'of type Range' do

      it 'should work for integer ranges' do
        parse('1..10').should be == [1..10]
      end

      it 'should work for integer exclusive ranges' do
        parse('1...10').should be == [1...10]
      end

      it 'should work for float ranges' do
        parse('1.0..10.0').should be == [1.0..10.0]
      end

      it 'should work with context variables' do
        parse('a..b', {'a' => 1, 'b' => 10}).should be == [1..10]
      end

    end

    context 'of type "context var"' do

      it 'should work' do
        parse('myvar', {'myvar' => 'myvalue'}).should be == ['myvalue']
      end

      it 'can call methods without arguments' do
        parse('myvar.length', {'myvar' => ' myvalue '}).should be == [9]
      end

      it 'can call methods without arguments on immediate values' do
        parse('"foobar".length').should be == [6]
      end

      it 'can call a method with arguments' do
        parse('myvar.split(",", 2)', {'myvar' => 'foo,bar'}).should be == [%w(foo bar)]
      end

      it 'can call a method with context var arguments' do
        parse('myvar.split(myseparator, 2)', {'myvar' => 'foo,bar', 'myseparator' => ','}).should be == [%w(foo bar)]
      end

      it 'can evaluate context var deeply unclosed in collections' do
        parse('[{1 => [{2 => myvar}]}]', {'myvar' => 'myvalue'}).first.should be == [{1 => [{2 => 'myvalue'}]}]
      end

      it 'can call methods chain without arguments' do
        parse('myvar.strip.length', {'myvar' => ' myvalue '}).should be == [7]
      end

      it 'can call predicate methods' do
        parse('myvar.empty?', {'myvar' => ' myvalue '}).should be == [false]
      end

      it 'can get a hash value' do
        parse('myvar.mykey', {'myvar' => {'mykey' => 'myvalue'}}).should be == ['myvalue']
      end

      it 'can fallback on Liquid::Drop#before_method' do
        parse('myvar.mymethod', {'myvar' => DummyDrop.new}).should be == ['dummy mymethod']
      end

      it 'should manage errors'

    end

    context 'of type "named parameter"' do

      it 'should be able to parse a string' do
        parse('foo:"bar"').should be == [{:foo => 'bar'}]
      end

      it 'should be able to parse an int' do
        parse('foo:42').should be == [{:foo => 42}]
      end

      it 'should be able to parse a context var' do
        parse('foo:bar', {'bar' => 'baz'}).should be == [{:foo => 'baz'}]
      end

      it "should not be disturbed by a comma into a named string" do
        parse('foo:"bar,baz"').should be == [{:foo => 'bar,baz'}]
      end

      it "should support a mix of types" do
        parse('foo:"bar",bar:42, baz:true, egg:spam', {'spam' => 'egg'}).should be == [{
          foo: 'bar',
          bar: 42,
          baz: true,
          egg: 'egg',
        }]
      end

    end

  end

  context 'with multiple arguments' do

    it 'should return 3 arguments and an option hash' do
      args = parse('1, "2", myvar, myopt:false', {'myvar' => 4.2})
      args.should be == [1, '2', 4.2, {:myopt => false}]
    end

    it 'should be tolerant about whitespace around commas and colons' do
      args = parse("    1\t, '2'  ,myvar, myopt: false", {'myvar' => 4.2})
      args.should be == [1, '2', 4.2, {:myopt => false}]
    end

  end

end
