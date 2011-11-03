require 'liquid'

module Solid
  BASE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'solid')

  autoload :Arguments,        File.join(BASE_PATH, 'arguments')
  autoload :Block,            File.join(BASE_PATH, 'block')
  autoload :ConditionalBlock, File.join(BASE_PATH, 'conditional_block')
  autoload :Element,          File.join(BASE_PATH, 'element')
  autoload :Tag,              File.join(BASE_PATH, 'tag')
  autoload :VERSION,          File.join(BASE_PATH, 'version')
end
