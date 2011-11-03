require 'liquid'

module Solid
  BASE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), 'solid')

  autoload :Arguments, File.join(BASE_PATH, 'arguments')
  autoload :Tag, File.join(BASE_PATH, 'tag')
  autoload :VERSION, File.join(BASE_PATH, 'version')
end
