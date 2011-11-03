class Solid::ConditionalBlock < Liquid::If

  include Solid::Element

  def render(context)
    display(*arguments.parse(context)) do |condition_satisfied|
      render_content(context, condition_satisfied)
    end
  end

  protected
  def render_content(context, render_main_block)
    context.stack do
      @blocks.each do |block|
        if render_main_block ^ block.else?
          return render_all(block.attachment, context)
        end
      end
      ''
    end
  end

end