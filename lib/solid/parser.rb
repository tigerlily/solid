class Solid::Parser

  BASE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'parser')

  autoload :Ripper, File.join(BASE_PATH, 'ripper')
  autoload :RubyParser, File.join(BASE_PATH, 'ruby_parser')

  class ContextVariable < Struct.new(:name)
    def evaluate(context)
      Solid.to_liquid(context[name], context)
    end
  end

  class Literal < Struct.new(:value)
    def evaluate(context)
      Solid.to_liquid(value, context)
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
    include Solid::MethodWhitelist
    BUILTIN_HANDLERS = {
      :'&&' => ->(left, right) { left && right },
      :'||' => ->(left, right) { left || right },
      :'and' => ->(left, right) { left and right },
      :'or' => ->(left, right) { left or right }
    }

    def evaluate(context)
      Solid.to_liquid(pluck(receiver.evaluate(context), name, *arguments.map {|arg| arg.evaluate(context) }), context)
    end

    protected

    def pluck(object, method, *args)
      if BUILTIN_HANDLERS.has_key?(method)
        BUILTIN_HANDLERS[method].call(object, *args)
      elsif safely_respond_to?(object, method)
        object.public_send(method, *args)
      elsif object.respond_to?(:[]) && args.empty?
        object[method]
      elsif object.respond_to?(:before_method)
        object.before_method(method, *args)
      end
    end

  end

  KEYWORDS = {
    'true' => Literal.new(true),
    'false' => Literal.new(false),
    'nil' => Literal.new(nil),
  }

  class << self

    attr_writer :parser

    def parser
      @parser || Solid::Parser::RubyParser
    end

    def parse(string)
      parser.parse(string)
    end

  end

end
