class Solid::Tag < Liquid::Tag

  include Solid::Element

  def render(context)
    with_context(context) do
      display(*arguments.interpolate(context))
    end
  end

end