RSpec::Matchers.define :safely_respond_to do |method_name|
  match do |object|
    Solid::MethodWhitelist.safely_respond_to?(object, method_name)
  end
end

def it_should_safely_respond_to(*methods)
  methods.each do |method|
    it { should safely_respond_to method }
  end
end

def it_should_not_safely_respond_to(*methods)
  methods.each do |method|
    it { should_not safely_respond_to method }
  end
end
