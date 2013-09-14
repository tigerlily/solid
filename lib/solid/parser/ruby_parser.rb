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
    case literal
    when Range
      LiteralRange.new(Literal.new(literal.first), Literal.new(literal.last), literal.exclude_end?)
    else
      Literal.new(literal)
    end
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

  def handle_true
    KEYWORDS['true']
  end

  def handle_false
    KEYWORDS['false']
  end

  def handle_nil
    KEYWORDS['nil']
  end

  def handle_const(const_name)
    ContextVariable.new(const_name.to_s)
  end

  def handle_call(receiver, method_name, *arguments)
    return ContextVariable.new(method_name.to_s) if receiver.nil?

    MethodCall.new(parse_one(receiver), method_name, arguments.map(&method(:parse_one)))
  end
end
