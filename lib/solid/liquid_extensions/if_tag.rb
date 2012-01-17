module Solid
  module LiquidExtensions
    class IfTag < Liquid::Block
      include Solid::Element
      extend TagHighjacker

      tag_name :if

      def initialize(tag_name, expression, tokens)
        @blocks = []
        push_block!(expression)
        super
      end

      def render(context)
        with_context(context) do
          @blocks.each do |expression, blocks|
            if expression.evaluate(context)
              return render_all(blocks, context)
            end
          end
        end
        ''
      end

      def unknown_tag(tag, expression, tokens)
        if tag == 'elsif'
          push_block!(expression)
        elsif tag == 'else'
          push_block!('true')
        end
      end

      protected

      def push_block!(expression)
        block = []
        @blocks.push([Solid::Parser.parse(expression), block])
        @nodelist = block
      end

    end
  end
end
