module Solid
  module LiquidExtensions
    class UnlessTag < Solid::LiquidExtensions::IfTag

      tag_name :unless

      def initialize(tag_name, expression, tokens)
        super(tag_name, "!(#{expression})", tokens)
      end

    end
  end
end
