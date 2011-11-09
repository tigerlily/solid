class Solid::Template < Liquid::Template

  include Enumerable

  class << self

    def parse(source)
      template = Solid::Template.new
      template.parse(source)
      template
    end

  end

  def each(&block)
    self.walk(&block)
  end

  protected
  def walk(nodes=nil, &block)
    (nodes || root.nodelist).each do |node|
      yield node
      walk(node.nodelist, &block) if node.respond_to?(:nodelist)
    end
  end

end