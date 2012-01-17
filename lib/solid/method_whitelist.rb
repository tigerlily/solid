module Solid
  module MethodWhitelist
    extend self

    METHODS_WHITELIST = {}
    METHODS_BLACKLIST = {}

    class << self

      def allow(rules)
        rules.each do |owner, method_names|
          list = METHODS_WHITELIST[owner] ||= Set.new
          [method_names].flatten.each do |method_name|
            list.add(method_name.to_sym)
          end
        end
        self
      end

      def deny(rules)
        rules.each do |owner, method_names|
          list = METHODS_BLACKLIST[owner] ||= Set.new
          [method_names].flatten.each do |method_name|
            list.add(method_name.to_sym)
          end
        end
        self
      end

    end

    def safely_respond_to?(object, method)
      return false unless object.respond_to?(method, false)
      method = object.method(method)
      (!inherited?(object, method) || whitelisted?(method)) && !blacklisted?(method)
    end
    module_function :safely_respond_to?

    private

    def whitelisted?(method)
      METHODS_WHITELIST.has_key?(method.owner) && METHODS_WHITELIST[method.owner].include?(method.name)
    end

    def blacklisted?(method)
      METHODS_BLACKLIST.has_key?(method.owner) && METHODS_BLACKLIST[method.owner].include?(method.name)
    end

    def inherited?(object, method)
      method.owner != object.class && !object.methods(false).include?(method.name)
    end

  end
end

require File.join(File.expand_path(File.dirname(__FILE__)), 'default_security_rules')
