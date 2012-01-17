module LiquidSafe
  def to_liquid
    self
  end
end

class Symbol
  include LiquidSafe
end

class Regexp
  include LiquidSafe
end

class Time
  extend LiquidSafe
end
