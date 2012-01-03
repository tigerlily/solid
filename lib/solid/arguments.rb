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
      return Solid.unproxify(methods.inject(object) { |obj, method| obj.public_send(method) })
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