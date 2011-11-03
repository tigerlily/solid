module Solid::Element

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods

    def initialize(tag_name, arguments_string, tokens)
       super
       @arguments = Solid::Arguments.new(arguments_string)
    end

    def arguments
      @arguments
    end

    def display(*args)
      raise NotImplementedError.new("#{self.class.name} subclasses SHOULD define a #display method")
    end
    
  end

  module ClassMethods

    def tag_name(value=nil)
      if value
        @tag_name = value
        Liquid::Template.register_tag(value, self)
      end
      @tag_name
    end

  end

end