require 'liquid'

module Solid
  BASE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'solid')

  require File.join(BASE_PATH, 'extensions')

  autoload :Argument,         File.join(BASE_PATH, 'argument')
  autoload :Arguments,        File.join(BASE_PATH, 'arguments')
  autoload :Block,            File.join(BASE_PATH, 'block')
  autoload :ConditionalBlock, File.join(BASE_PATH, 'conditional_block')
  autoload :ContextError,     File.join(BASE_PATH, 'context_error')
  autoload :Element,          File.join(BASE_PATH, 'element')
  autoload :Iterable,         File.join(BASE_PATH, 'iterable')
  autoload :MethodWhitelist,  File.join(BASE_PATH, 'method_whitelist')
  autoload :Parser,           File.join(BASE_PATH, 'parser')
  autoload :Tag,              File.join(BASE_PATH, 'tag')
  autoload :Template,         File.join(BASE_PATH, 'template')
  autoload :VERSION,          File.join(BASE_PATH, 'version')

  if defined?(Rails) # Rails only features
    autoload :ModelDrop,      File.join(BASE_PATH, 'model_drop')
    require File.join(BASE_PATH, 'engine')
  end

  require File.join(BASE_PATH, 'liquid_extensions')

  class << self

    def unproxify(object)
      class_name = object.class.name
      if class_name && class_name.end_with?('::LiquidDropClass')
        return object.instance_variable_get('@object')
      end
      object
    end

    def to_liquid(object, context)
      object = object.to_liquid
      object.context = context if object.respond_to?(:context=)
      object
    end

  end

  SyntaxError = Class.new(Liquid::SyntaxError)

end
