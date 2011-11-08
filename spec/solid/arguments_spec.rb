require 'spec_helper'

describe Solid::Arguments do

  def parse(string, context={})
    Solid::Arguments.new(string).parse(context)
  end

  context 'with a single argument' do

    context 'of type string' do

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

    end

    context 'of type integer' do

      it 'should works' do
        parse('42').should be == [42]
      end

    end

    context 'of type float' do

      it 'should works' do
        parse('4.2').should be == [4.2]
      end

    end

    context 'of type boolean' do

      it 'should works with `true`' do
        parse('true').should be == [true]
      end

      it 'should works with `false`' do
        parse('false').should be == [false]
      end

    end

    context 'of type "context var"' do

      it 'should works' do
        parse('myvar', {'myvar' => 'myvalue'}).should be == ['myvalue']
      end

      it 'can call methods without arguments' do
        parse('myvar.length', {'myvar' => ' myvalue '}).should be == [9]
      end

      it 'can call methods chain without arguments' do
        parse('myvar.strip.length', {'myvar' => ' myvalue '}).should be == [7]
      end

      it 'can call predicate methods' do
        parse('myvar.empty?', {'myvar' => ' myvalue '}).should be == [false]
      end

      it 'should manage errors'

    end

    context 'of type "named parameter"' do

      it 'should be able to parse a string' do
        parse('foo:"bar"').should be == [{foo: 'bar'}]
      end

      it 'should be able to parse an int' do
        parse('foo:42').should be == [{foo: 42}]
      end

      it 'should be able to parse a context var' do
        parse('foo:bar', {'bar' => 'baz'}).should be == [{foo: 'baz'}]
      end

      it "should not be disturbed by a comma into a named string" do
        parse('foo:"bar,baz"').should be == [{foo: 'bar,baz'}]
      end

    end

  end

  context 'with multiple arguments' do

    it 'should return 3 arguments and an option hash' do
      args = parse('1, "2", myvar, myopt:false', {'myvar' => 4.2})
      args.should be == [1, '2', 4.2, {myopt: false}]
    end

    it 'should be tolerent about whitespaces around commas and colons' do
      args = parse("    1\t, '2'  ,myvar, myopt: false", {'myvar' => 4.2})
      args.should be == [1, '2', 4.2, {myopt: false}]
    end

  end

end
