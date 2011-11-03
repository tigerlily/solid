class Solid::Arguments

  def initialize(string)
    @string = string
  end

  def transform(arg, context)
    arg.strip!
    # Named arguments
    if arg =~ /^([\w\_][\w\_\d]*)\:(.*)$/
      return $1.to_sym, transform($2, context)
    end

    # Booleans
    return true if arg == 'true'
    return false if arg == 'false'

    # Strings
    if arg.start_with?('"') && arg.end_with?('"') || arg.start_with?("'") && arg.end_with?("'")
      return arg.gsub(/^[\'\"]/, '').gsub(/[\'\"]$/, '')
    end

    # Integers
    return Integer(arg) if arg =~ /^\d+$/

    # Floats
    return Float(arg) if arg =~ /^[\d\.]+$/
    
    return context[arg]
  end

  def parse(context)
    args = @string.split(/\,\s*/)
    args.map!{ |arg| transform(arg, context) }
    args, options = args.partition{ |arg| !arg.is_a?(Array) }
    args << Hash[options] if options.any?
    args
  end

end