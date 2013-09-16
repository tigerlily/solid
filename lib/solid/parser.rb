class Solid::Parser

  BASE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'parser')

  begin
    require 'ripper'
    autoload :Ripper, File.join(BASE_PATH, 'ripper')
  rescue LoadError
  end
  begin
    require 'ruby_parser'
    autoload :RubyParser, File.join(BASE_PATH, 'ruby_parser')
  rescue LoadError
  end

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
    BUILTIN_HANDLERS.keys.each do |operator|
      BUILTIN_HANDLERS[operator.to_s] = BUILTIN_HANDLERS[operator]
    end

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
      @parser || begin
        if defined?(Solid::Parser::RubyParser)
          Solid::Parser::RubyParser
        elsif defined?(Solid::Parser::Ripper)
          Solid::Parser::Ripper
        else
          raise "You need to run MRI (to have Ripper), "\
            "or have 'ruby_parser' in $LOAD_PATH "\
            "or set #{self}.parser yourself"
        end
      end
    end

    def parse(string)
      parser.parse(string)
    end

  end

end
