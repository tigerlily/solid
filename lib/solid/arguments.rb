class Solid::Arguments

  def initialize(string)
    @string = string
  end

  def parse(context)
    args = []
    @string.split(Solid::Argument::SEPARATOR).map{ |arg| Solid::Argument.new(arg) }.each do |argument|
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