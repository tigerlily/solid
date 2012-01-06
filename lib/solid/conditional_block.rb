class Solid::ConditionalBlock < Liquid::Block
  include Solid::Element

  def initialize(tag_name, variable, tokens)
    @blocks = []
    push_block!
    super
  end

  def render(context)
    with_context(context) do
      display(*arguments.interpolate(context)) do |condition_satisfied|
        block = condition_satisfied ? @blocks.first : @blocks.last
        render_all(block, context)
      end
    end
  end

  def unknown_tag(tag, markup, tokens)
    if tag == 'else'
      push_block!
    else
      super
    end
  end

  private

  def push_block!
    block = []
    @blocks.push(block)
    @nodelist = block
  end

end
