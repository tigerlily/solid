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

  end

end
