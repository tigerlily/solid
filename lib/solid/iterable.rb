module Solid
  module Iterable
    include Enumerable

    def each(&block)
      self.walk(&block)
    end

    protected
    def walk(nodes=nil, &block)
      (nodes || self.nodelist).each do |node|
        yield node
        walk(node.nodelist || [], &block) if node.respond_to?(:nodelist)
      end
    end

  end
end