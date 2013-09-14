require 'ruby_parser'

class Solid::Parser::RubyParser < Solid::Parser

  def self.parse(string)
    new(string).parse
  end

  def initialize(expression)
    @expression = expression
  end

  def parse
    @sexp = ::RubyParser.new.parse(@expression)
    parse_one(@sexp)
  end

  def parse_one(expression)
    type = expression.shift
    handler = "handle_#{type}"
    raise Solid::SyntaxError, "unknown expression type: #{type.inspect}" unless respond_to?(handler)
    public_send handler, *expression
  end

  def handle_lit(literal)
    Literal.new(literal)
  end

  def handle_str(literal)
    Literal.new(literal)
  end

  def handle_array(*array_values)
    LiteralArray.new(array_values.map(&method(:parse_one)))
  end

  def handle_hash(*hash_keys_and_values)
    LiteralHash.new(Hash[*hash_keys_and_values.map(&method(:parse_one))])
  end

end
