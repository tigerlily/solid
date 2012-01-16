module Solid
  module LiquidExtensions
    class Variable < ::Liquid::Variable
      extend ClassHighjacker

      def initialize(markup)
        super
        @expression = Solid::Parser.parse(@name)
      end

      def render(context)
        return '' if @name.nil?
        value = @expression.evaluate(context)
        apply_filters_on(value, context)
      end

      protected

      def apply_filters_on(value, context)
        @filters.inject(value) do |output, filter|
          filterargs = filter[1].to_a.collect do |a|
            context[a]
          end
          begin
            output = context.invoke(filter[0], output, *filterargs)
          rescue FilterNotFound
            raise FilterNotFound, "Error - filter '#{filter[0]}' in '#{@markup.strip}' could not be found."
          end
        end
      end

    end
  end
end
