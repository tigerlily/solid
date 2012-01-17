module Solid
  module MethodWhitelist

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
      (method.owner == object.class || whitelisted?(method)) &&
				!blacklisted?(method)
    end

    def whitelisted?(method)
      METHODS_WHITELIST.has_key?(method.owner) && METHODS_WHITELIST[method.owner].include?(method.name)
    end

		def blacklisted?(method)
      METHODS_BLACKLIST.has_key?(method.owner) && METHODS_BLACKLIST[method.owner].include?(method.name)
		end

    module_function :safely_respond_to?, :whitelisted?, :blacklisted?

  end
end

require File.join(File.expand_path(File.dirname(__FILE__)), 'default_security_rules')
