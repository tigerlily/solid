module LiquidSafe
  def to_liquid
    self
  end
end

class Symbol
  include LiquidSafe
end
