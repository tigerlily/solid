class Solid::Tag < Liquid::Tag

  include Solid::Element

  def render(context)
    with_context(context) do
      display(*arguments.interpolate(context).map(&Solid.method(:unproxify)))
    end
  end

end