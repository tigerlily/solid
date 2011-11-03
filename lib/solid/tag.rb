class Solid::Tag < Liquid::Tag

  include Solid::Element

  def render(context)
    with_context(context) do
      display(*arguments.parse(context))
    end
  end

end