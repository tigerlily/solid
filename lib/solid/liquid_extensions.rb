module Solid

  class << self

    def extend_liquid!
      LiquidExtensions.load!
    end

  end

  module LiquidExtensions

    module ClassHighjacker

      def load!
        original_classes[demodulized_name] = Liquid.send(:remove_const, demodulized_name)
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

    BASE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'liquid_extensions')

    require File.join(BASE_PATH, 'variable')

    ALL = [Variable]

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
