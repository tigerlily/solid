class Solid::Arguments

  SEPARATOR = ','

  class Argument

    SURROUNDING_CHARS = %w( " ' )

    attr_accessor :literal

    def initialize(literal)
      @literal = literal
    end

    def unterminated?
      striped = @literal.strip
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
      if striped =~ /^([\w\_][\w\_\d]*)\:(.*)$/
        return $1.to_sym, Argument.new($2).transform(context)
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

  def initialize(string)
    @string = string
  end

  def parse(context)
    args = []
    @string.split(SEPARATOR).map{ |arg| Argument.new(arg) }.each do |argument|
      if args.last && args.last.unterminated?
        args.last << argument
      else
        args << argument
      end
    end

    args = args.map{ |arg| arg.transform(context) }
    args, options = args.partition{ |arg| !arg.is_a?(Array) }
    args << Hash[options] if options.any?
    args
  end

end