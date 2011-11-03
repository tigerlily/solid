class Solid::Block < Liquid::Block

  include Solid::Element

  def render(context)
    with_context(context) do
      display(*arguments.parse(context)) do
        super
      end
    end
  end

end
