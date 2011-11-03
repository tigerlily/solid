class Solid::Tag < Liquid::Tag

  include Solid::Element

  def render(context)
    display(*arguments.parse(context))
  end

end