module Solid
  module LiquidExtensions

    # This for block reimplementation is deliberately backward incompatible
    # since all strange features supported by the original for loop like
    # "reversed" or "limit: 20 offset: 40" are favourably replaced by pure ruby
    # methods like `Array#reversed` or `Array#slice`
    class ForTag < Solid::Block
      PAGINATION_METHODS = [:current_page, :per_page, :total_entries, :offset].freeze

      extend TagHighjacker

      tag_name :for

      def initialize(tag_name, expression, tokens)
        @variable_name, iterable_expression = expression.split(/\s+in\s+/, 2).map(&:strip)
        super(tag_name, iterable_expression, tokens)
      end

      def display(collection)
        forloop = loop_for(collection)
        output = []
        collection = [] unless collection.respond_to?(:each_with_index)
        collection.each_with_index do |element, index|
          current_context.stack do
            current_context[@variable_name] = element.to_liquid
            current_context['forloop'] = forloop
            output << yield
            forloop.inc!
          end
        end
        output.join
      end

      protected
      def loop_for(collection)
        if paginated?(collection)
          PaginatedForLoop.new(collection)
        else
          ForLoop.new(collection)
        end
      end

      def paginated?(collection)
        PAGINATION_METHODS.all?{ |m| collection.respond_to?(m) } &&
        !collection.per_page.nil? # The only way to see if a Mongoid::Criteria is paginated with WillPaginate
      end

    end

    class ForLoop < Liquid::Drop

      def initialize(collection)
        @collection = collection
        @index0 = 0
      end

      def index0
        @index0
      end

      def index
        index0 + 1
      end

      def rindex
        length - index0
      end

      def rindex0
        length - index0 - 1
      end

      def length
        @collection.length
      end

      def first
        index0 == 0
      end

      def last
        index == length - 1
      end

      def inc!
         @index0 += 1
      end

    end

    class PaginatedForLoop < ForLoop

      def initialize(collection)
        super
        @index0 = collection.offset || 0
      end

    end

  end
end

