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
    self.values = Solid::Parser.new(@string).parse
    self
  end

  def each(*args, &block)
    values.each(*args, &block)
  end

  def interpolate(context)
    values.map {|value| value.evaluate(context) }
  end
end
