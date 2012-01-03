require 'forwardable'

class Solid::Template < Liquid::Template
  extend Forwardable
  include Solid::Iterable

  class << self

    def parse(source)
      template = Solid::Template.new
      template.parse(source)
      template
    end

  end

  def_delegators :root, :nodelist

  # Avoid issues with ActiveSupport::Cache which freeze all objects passed to it like an ass
  # And anyway once frozen Liquid::Templates are unable to render anything
  def freeze
  end

end
