require 'ripper'

class Solid::Arguments
  include Enumerable

  def self.parse(string)
    new(string).parse!
  end

  attr_accessor :values

  def initialize(string)
    @string = string
  end

  def parse!
    self.values = Parser.new(@string).parse
    self
  end

  def each(*args, &block)
    values.each(*args, &block)
  end

  def interpolate(context)
    values.map {|value| value.evaluate(context) }
  end

  class ContextVariable < Struct.new(:name)
    def evaluate(context)
      context[name].to_liquid
    end
  end

  class Literal < Struct.new(:value)
    def evaluate(context)
      value.to_liquid
    end
  end

  class LiteralArray < Literal
    def evaluate(context)
      value.map{ |v| v.evaluate(context) }
    end
  end

  class LiteralRange < Struct.new(:start_value, :end_value, :exclusive)
    def evaluate(context)
      Range.new(start_value.evaluate(context), end_value.evaluate(context), exclusive)
    end
  end

  class LiteralHash < Literal
    def evaluate(context)
      Hash[value.map{ |k, v| [k.evaluate(context), v.evaluate(context)] }]
    end
  end

  class MethodCall < Struct.new(:receiver, :name, :arguments)
    BUILTIN_HANDLERS = {
      :'&&' => ->(left, right) { left && right },
      :'||' => ->(left, right) { left || right }
    }

    def evaluate(context)
      pluck(receiver.evaluate(context), name, *arguments.map {|arg| arg.evaluate(context) }).to_liquid
    end

    def pluck(object, method, *args)
      if BUILTIN_HANDLERS.has_key?(method)
        BUILTIN_HANDLERS[method].call(object, *args)
      elsif object.respond_to?(method, false) # do not include private methods
        object.public_send(method, *args)
      elsif object.respond_to?(:[]) && args.empty?
        object[method]
      elsif object.respond_to?(:before_method)
        object.before_method(method, *args)
      end
    end

  end

  class Parser
    def initialize(string)
      @string = "[#{string}]"
      @sexp = nil
    end

    def parse
      @sexp = Ripper.sexp(@string)
      dive_in or raise 'Ripper changed?'
      @sexp.map do |argument|
        parse_one(argument)
      end
    end

    # Looks for a structure like
    # [:program, [[:array, [#stuff#]]]] or
    # [:program, [[:array, nil]]]
    def dive_in
      @sexp = @sexp[1]
      @sexp = @sexp.first
      @sexp = @sexp[1] || []
    end

    def parse_one(argument)
      type = argument.shift
      handler = "handle_#{type.to_s.sub('@', '')}"
      raise SyntaxError, "unknown Ripper type: #{type}" unless respond_to?(handler)
      public_send handler, *argument
    end

    # # spam
    # [:@ident, "spam", [1, 33]] or
    # # true
    # [:@kw, "true", [1, 23]]
    def handle_var_ref(var_ref)
      parse_one(var_ref)
    end

    # # foo: 42
    # [[:assoc_new, [:@label, "foo:", [1, 1]], [:@int, "42", [1, 5]]]]
    def handle_bare_assoc_hash(assoc_hash)
      LiteralHash.new assoc_hash.map {|(_, *key_value)| key_value.map(&method(:parse_one)) }
    end

    # # {foo: 42}
    # [:assoclist_from_args, [[:assoc_new, [:@label, "foo:", [1, 2]], [:@int, "42", [1, 7]]]]]
    def handle_hash(hash)
      handle_bare_assoc_hash(hash.last)
    end

    # # myvar.length
    #
    # [:var_ref, [:@ident, "myvar", [1, 1]]]
    # :"."
    # [:@ident, "length", [1, 7]]
    def handle_call(receiver_sexp, method_call, method_sexp)
      receiver = parse_one(receiver_sexp)
      method = method_sexp[1]
      MethodCall.new receiver, method, []
    end

    # # myvar.split(',', 2)
    #
    # [:call, [:var_ref, [:@ident, "myvar", [1, 1]]], :".", [:@ident, "split", [1, 7]]]
    # [:arg_paren, [:args_add_block, [
    #     [:string_literal, [:string_content, [:@tstring_content, ",", [1, 14]]]],
    #     [:@int, "2", [1, 18]]
    #   ], false]]
    def handle_method_add_arg(call_sexp, args_sexp)
      method_call = parse_one(call_sexp)
      method_call.arguments = method_call_args(args_sexp)
      method_call
    end

    # # args list: (',', 2)
    # [:arg_paren, [:args_add_block, [
    #     [:string_literal, [:string_content, [:@tstring_content, ",", [1, 14]]]],
    #     [:@int, "2", [1, 18]]
    #   ], false]]
    def method_call_args(args_sexp)
      args_sexp = args_sexp.last[1]
      args_sexp.map(&method(:parse_one))
    end

    # # 1 + 2
    # [:@int, "1", [1, 0]], :*, [:@int, "2", [1, 4]]
    def handle_binary(left_operand, operator, right_operand)
      receiver = parse_one(left_operand)
      MethodCall.new(receiver, operator, [parse_one(right_operand)])
    end

    # # [1]
    # [[:@int, "1", [1, 1]]
    def handle_array(array)
      LiteralArray.new array.map(&method(:parse_one))
    end

    # # (1)
    # [[:@int, "42", [1, 2]]]
    def handle_paren(content)
      parse_one(content.first)
    end

    # # 1..10
    # [[:@int, "1", [1, 0]], [:@int, "10", [1, 4]]]
    def handle_dot2(start_value, end_value)
      LiteralRange.new(parse_one(start_value), parse_one(end_value), false)
    end

    # # 1...10
    # [[:@int, "1", [1, 0]], [:@int, "10", [1, 4]]]
    def handle_dot3(start_value, end_value)
      LiteralRange.new(parse_one(start_value), parse_one(end_value), true)
    end

    # # 'mystring'
    # [:string_content, [:@tstring_content, "mystring", [1, 14]]]
    # TODO: handle string interpolation
    def handle_string_literal(string_literal)
      Literal.new(string_literal.last[1])
    end

    # # /bb|[^b]{2}/
    # [[:@tstring_content, "bb|[^b]{2}", [1, 2]]].first.first
    # TODO: handle regexp interpolation
    def handle_regexp_literal(regexp_literal, lineno_column)
      Literal.new Regexp.new(regexp_literal.first[1])
    end

    KEYWORDS = {
      'true' => Literal.new(true),
      'false' => Literal.new(false),
      'nil' => Literal.new(nil),
    }
    # # true
    # "true", [1, 33]
    def handle_kw(keyword, lineno_column)
      raise 'unknown Ripper sexp' unless KEYWORDS.has_key? keyword
      KEYWORDS[keyword]
    end

    # # spam
    # "spam", [1, 23]
    def handle_ident(identifier, lineno_column)
      ContextVariable.new identifier
    end

    # # Spam
    # "Spam", [1, 23]
    def handle_const(constant, lineno_column)
      ContextVariable.new constant
    end

    # # 42
    # "42", [1, 2]
    def handle_int(int, lineno_column)
      Literal.new int.to_i
    end

    # # 4.2
    # "4.2", [1, 2]
    def handle_float(float, lineno_column)
      Literal.new float.to_f
    end

    # # foo:
    # "foo:", [1, 2]
    def handle_label(label, lineno_column)
      Literal.new label[0..-2].to_sym
    end
  end
end
