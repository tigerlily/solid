class Solid::Argument

  SEPARATOR = ','

  SURROUNDING_CHARS = %w( " ' )

  NAMED_ARGUMENT_RE = /^([\w\_][\w\_\d]*)\:(.*)$/

  attr_accessor :literal

  def initialize(literal)
    @literal = literal
  end

  def unterminated?
    striped = @literal.strip

    if striped =~ NAMED_ARGUMENT_RE
      striped = $2.strip
    end

    SURROUNDING_CHARS.each do |char|
      if striped.start_with?(char) && !striped.end_with?(char)
        return char
      end
    end
    false
  end

  def transform(context)
    striped = literal.strip
    # Named arguments
    if striped =~ NAMED_ARGUMENT_RE
      return $1.to_sym, Solid::Argument.new($2).transform(context)
    end

    # Booleans
    return true if striped == 'true'
    return false if striped == 'false'

    # Strings
    if striped.start_with?('"') && striped.end_with?('"') || striped.start_with?("'") && striped.end_with?("'")
      return striped.gsub(/^[\'\"]/, '').gsub(/[\'\"]$/, '')
    end

    # Integers
    return Integer(striped) if striped =~ /^\d+$/

    # Floats
    return Float(striped) if striped =~ /^[\d\.]+$/

    # Context var
    var, *methods = striped.split('.')
    object = context[var]
    return Solid.unproxify(methods.inject(object) { |obj, method| obj.public_send(method) })
  end

  def <<(other)
    self.literal << SEPARATOR << other.literal
    self
  end

end
