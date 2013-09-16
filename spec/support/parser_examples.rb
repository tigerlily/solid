RSpec::Matchers.define :evaluate_to do |value|

  match do |expression|
    expression.evaluate(context).should be == value
  end

end

shared_examples 'a solid parser' do

  let(:parser) { described_class }

  let(:context) { {} }

  context 'literals parsing' do

    it 'is able to parse an Integer' do
      exp = parser.parse('42')
      exp.should be_a Solid::Parser::Literal
      exp.should evaluate_to 42
    end

    it 'is able to parse a Float' do
      exp = parser.parse('4.2')
      exp.should be_a Solid::Parser::Literal
      exp.should evaluate_to 4.2
    end

    it 'is able to parse a String' do
      exp = parser.parse('"foo"')
      exp.should be_a Solid::Parser::Literal
      exp.should evaluate_to 'foo'
    end

    it 'is able to parse a single quoted String' do
      exp = parser.parse("'foo'")
      exp.should be_a Solid::Parser::Literal
      exp.should evaluate_to 'foo'
    end

    it 'is able to parse an Array' do
      exp = parser.parse('[1, 2, 3]')
      exp.should be_a Solid::Parser::LiteralArray
      exp.should evaluate_to [1, 2, 3]
    end

    it 'is able to parse an empty Array' do
      exp = parser.parse('[]')
      exp.should be_a Solid::Parser::LiteralArray
      exp.should evaluate_to []
    end

    it 'is able to parse a inclusive Range' do
      exp = parser.parse('1..10')
      exp.should be_a Solid::Parser::LiteralRange
      exp.should evaluate_to 1..10
    end

    it 'is able to parse a exclusive Range' do
      exp = parser.parse('1...10')
      exp.should be_a Solid::Parser::LiteralRange
      exp.should evaluate_to 1...10
    end

    it 'is able to parse a inclusive Range of Float' do
      exp = parser.parse('1.0..10.0')
      exp.should be_a Solid::Parser::LiteralRange
      exp.should evaluate_to 1.0..10.0
    end

    it 'is able to parse a exclusive Range of Float' do
      exp = parser.parse('1.0...10.0')
      exp.should be_a Solid::Parser::LiteralRange
      exp.should evaluate_to 1.0...10.0
    end

    it 'is able to parse a Hash' do
      exp = parser.parse('{1 => 2, 3 => 4}')
      exp.should be_a Solid::Parser::LiteralHash
      exp.should evaluate_to({1 => 2, 3 => 4})
    end

    it 'is able to parse an empty Hash' do
      exp = parser.parse('{}')
      exp.should be_a Solid::Parser::LiteralHash
      exp.should evaluate_to({})
    end

    it 'is able to parse a simple Regex' do
      exp = parser.parse('/foo/')
      exp.should be_a Solid::Parser::Literal
      exp.should evaluate_to(/foo/)
    end

    it 'is able to parse a flagged Regex' do
      exp = parser.parse('/foo/x')
      exp.should be_a Solid::Parser::Literal
      exp.should evaluate_to(/foo/x)
    end

    it 'is able to parse a true Boolean' do
      exp = parser.parse('true')
      exp.should be_a Solid::Parser::Literal
      exp.should evaluate_to(true)
    end

    it 'is able to parse a false Boolean' do
      exp = parser.parse('false')
      exp.should be_a Solid::Parser::Literal
      exp.should evaluate_to(false)
    end

    it 'is able to parse a nil' do
      exp = parser.parse('nil')
      exp.should be_a Solid::Parser::Literal
      exp.should evaluate_to(nil)
    end

  end

  context 'constants and variable reference' do

    let(:context) { {'TRUTH' => 42, 'somevar' => 'foo'} }

    it 'is able to reference a simple constant' do
      exp = parser.parse('TRUTH')
      exp.should be_a Solid::Parser::ContextVariable
      exp.should evaluate_to(42)
    end

    it 'is able to reference a simple variable' do
      exp = parser.parse('somevar')
      exp.should be_a Solid::Parser::ContextVariable
      exp.should evaluate_to('foo')
    end

  end

  context 'methods calling' do

    class Dummy

      def echo(exp)
        exp
      end

      def [](key)
        key
      end

      def to_liquid
        self
      end

    end

    let(:context) { {'somevar' => 'foo', 'dummy' => Dummy.new, 'truth' => 42} }

    it 'is able to call simple methods without arguments' do
      exp = parser.parse('somevar.length')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(3)
    end

    it 'is able to call a method on a literal' do
      exp = parser.parse('"foo".length')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(3)
    end

    it 'is able to call a simple method ending with a "?"' do
      exp = parser.parse('somevar.nil?')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(false)
    end

    it 'is able to call a simple method ending with a "!"' do
      exp = parser.parse('somevar.strip!')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(nil)
    end

    it 'is able to call a method on nil' do
      exp = parser.parse('nil.nil?')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(true)
    end

    it 'is able to call a method with arguments' do
      exp = parser.parse('somevar.gsub("f", "b")')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to('boo')
    end

    it 'is able to call a method with unenclosed terminating hash' do
      exp = parser.parse('dummy.echo("foo" => "bar")')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to({"foo" => "bar"})
    end

    it 'is able to call "binary operator" methods' do
      exp = parser.parse('1 + 1')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(2)
    end

    it 'is able to call `-` "unary operator" methods' do
      exp = parser.parse('-truth')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(-42)
    end

    it 'is able to call `+` "unary operator" methods' do
      exp = parser.parse('+truth')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(42)
    end

    it 'is able to call `~` "unary operator" methods' do
      exp = parser.parse('~truth')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(-43)
    end

  end

  context 'boolean operators' do

    it 'is able to evaluate && expressions' do
      exp = parser.parse('true && true')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(true)
    end

    it 'is able to evaluate || expressions' do
      exp = parser.parse('true || false')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(true)
    end

    it 'is able to evaluate `and` expressions' do
      exp = parser.parse('true or true')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(true)
    end

    it 'is able to evaluate `or` expressions' do
      exp = parser.parse('true or false')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(true)
    end

    it 'is able to evaluate `!` expressions' do
      exp = parser.parse('!false')
      exp.should be_a Solid::Parser::MethodCall
      exp.should evaluate_to(true)
    end

  end

end
