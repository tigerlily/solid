RSpec::Matchers.define :safely_respond_to do |method_name|
  match do |object|
    Solid::MethodWhitelist.safely_respond_to?(object, method_name)
  end
end
