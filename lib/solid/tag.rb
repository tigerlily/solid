class Solid::Tag < Liquid::Tag
  
  def initialize(tag_name, arguments_string, tokens)
     super
     @arguments_string = arguments_string
  end

  def parse_arguments(arguments_string, context)
    args = arguments_string.split(/\,\s*/)
    args.map!{ |arg| transform(arg, context) }
    args, options = args.partition{ |arg| !arg.is_a?(Array) }
    args << Hash[options]
  end

  def transform(arg, context)
    puts "transform(#{arg.inspect}, #{context.inspect})"
    arg.strip!
    # Named arguments
    if arg =~ /([\w\_][\w\_\d]*)\:(.*)/
      return $1.to_sym, transform($2, context)
    end

    # Booleans
    return true if arg == 'true'
    return false if arg == 'false'

    # Strings
    if arg.starts_with?('"') && arg.ends_with?('"') || arg.starts_with?("'") && arg.ends_with?("'")
      return arg.gsub(/^[\'\"]/, '').gsub(/[\'\"]$/, '')
    end

    # Integers
    return Integer(arg) if arg =~ /\d+/

    # Floats
    return Float(arg) if arg =~ /[\d\.]+/
    
    return context[arg]
  end

  def arguments(context)
    @args ||= parse_arguments(@arguments_string, context)
  end

  def render(context)
    compute(*arguments(context))
  end

  def compute(*args)
    raise NotImplementedError.new
  end

end