module Solid::Element

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods

    def initialize(tag_name, arguments_string, tokens)
       super
       @arguments = Solid::Arguments.parse(arguments_string)
    end

    def arguments
      @arguments
    end

    def with_context(context)
      @current_context = context
      yield
    ensure
      @current_context = nil
    end

    def current_context
      @current_context or raise Solid::ContextError.new("There is currently no context, do you forget to call render ?")
    end

    def display(*args)
      raise NotImplementedError.new("#{self.class.name} subclasses SHOULD define a #display method")
    end
    
  end

  module ClassMethods

    def tag_name(value=nil)
      if value
        @tag_name = value
        Liquid::Template.register_tag(value.to_s, self)
      end
      @tag_name
    end

    def context_attribute(name)
      define_method(name) do
        Solid.unproxify(current_context[name.to_s])
      end
    end

  end

end