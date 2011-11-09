require 'liquid'

module Solid
  BASE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'solid')

  autoload :Argument,         File.join(BASE_PATH, 'argument')
  autoload :Arguments,        File.join(BASE_PATH, 'arguments')
  autoload :Block,            File.join(BASE_PATH, 'block')
  autoload :ConditionalBlock, File.join(BASE_PATH, 'conditional_block')
  autoload :ContextError,     File.join(BASE_PATH, 'context_error')
  autoload :Element,          File.join(BASE_PATH, 'element')
  autoload :Tag,              File.join(BASE_PATH, 'tag')
  autoload :Template,         File.join(BASE_PATH, 'template')
  autoload :VERSION,          File.join(BASE_PATH, 'version')

  class << self

    def unproxify(object)
      class_name = object.class.name
      if class_name && class_name.end_with?('::LiquidDropClass')
        return object.instance_variable_get('@object')
      end
      object
    end

  end

end
