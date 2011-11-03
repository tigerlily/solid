class Solid::Block < Liquid::Block

  include Solid::Element

  def render(context)
    display(*arguments.parse(context)) do
      super
    end
  end

end
