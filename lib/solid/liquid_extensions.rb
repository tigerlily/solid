module Solid

  class << self

    def extend_liquid!
      LiquidExtensions.load!
    end

  end

  module LiquidExtensions

    module ClassHighjacker

      def load!
        original_class = Liquid.send(:remove_const, demodulized_name)
        original_classes[demodulized_name] = original_class unless original_classes.has_key?(demodulized_name) # avoid loosing reference to original class
        Liquid.const_set(demodulized_name, self)
      end

      def unload!
        if original_class = original_classes[demodulized_name]
          Liquid.send(:remove_const, demodulized_name)
          Liquid.const_set(demodulized_name, original_classes)
        end
      end

      def demodulized_name
        @demodulized_name ||= self.name.split('::').last
      end

      protected
      def original_classes
        @@original_classes ||= {}
      end

    end

    module TagHighjacker

      def load!
        original_tag = Liquid::Template.tags[tag_name.to_s]
        original_tags[tag_name] = original_tag unless original_tags.has_key?(tag_name) # avoid loosing reference to original class
        Liquid::Template.register_tag(tag_name, self)
      end

      def unload!
        Liquid::Template.register_tag(tag_name, original_tags[tag_name])
      end

      def tag_name(name=nil)
        @tag_name = name unless name.nil?
        @tag_name
      end

      protected
      def original_tags
        @@original_tags ||= {}
      end

    end

    BASE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'liquid_extensions')

    %w(if_tag unless_tag variable).each do |mod|
      require File.join(BASE_PATH, mod)
    end

    ALL = [IfTag, UnlessTag, Variable]

    class << self

      def load!
        ALL.each(&:load!)
      end

      def unload!
        ALL.each(&:unload!)
      end

    end

  end

end
