class Solid::Tag < Liquid::Tag

  def initialize(tag_name, arguments_string, tokens)
     super
     @arguments = Solid::Arguments.new(arguments_string)
  end

  def render(context)
    display(*@arguments.parse(context))
  end

  def display(*args)
    raise NotImplementedError.new
  end

end