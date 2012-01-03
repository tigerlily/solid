require 'parsr'

class Solid::Arguments
  include Enumerable

  def self.parse(string)
    new('[%s]' % string).parse!
  end

  attr_accessor :values

  def initialize(string)
    @string = string
  end

  def parse!
    self.values = parser.parse(@string)
    self
  end

  def each(*args, &block)
    self.values.each(*args, &block)
  end

  def interpolate(context)
    interpolate_one(self.values, context)
  end

  protected

  def interpolate_one(value, context)
    case value
    when Solid::Arguments::ContextVariable
      value.evaluate(context)
    when Array
      value.map{ |v| interpolate_one(v, context) }
    when Hash
      Hash[value.map{ |k, v| [interpolate_one(k, context), interpolate_one(v, context)] }]
    else
      value
    end
  end

  def parser
    unless defined?(@@parser)
      rules = Parsr::Rules::All.dup
      rules.insert(Parsr::Rules::All.index(Parsr::Rules::Constants) + 1, Solid::Arguments::ContextVariableRule)
      @@parser = Parsr.new(*rules)
    end
    @@parser
  end

  class ContextVariable < Struct.new(:name)

    def evaluate(context)
      var, *methods = name.split('.')
      object = context[var]
      object = methods.inject(object) do |obj, method|
        if obj.respond_to?(:public_send)
          obj.public_send(method)
        else # 1.8 fallback
          obj.send(method) if obj.respond_to?(method, false)
        end
      end
      
      return Solid.unproxify(object)
    end

  end

  module ContextVariableRule

    PATTERN = /[a-zA-Z_][a-zA-Z\d_\.\!\?]*/

    class << self

      def match(scanner)
        if scanner.scan(PATTERN)
          variable = Solid::Arguments::ContextVariable.new(scanner.matched)
          return Parsr::Token.new(variable)
        end
      end

    end

  end

end