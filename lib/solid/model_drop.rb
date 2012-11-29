class Solid::ModelDrop < Liquid::Drop

  module ModelExtension
    extend ActiveSupport::Concern

    module ClassMethods

      def to_drop
        "#{self.name}Drop".constantize.new(current_scope || self)
      end

    end

  end

  class_attribute :dynamic_methods

  class << self

    def model(model_name=nil)
      if model_name
        @model_name = model_name
      else
        @model_name ||= self.name.gsub(/Drop$/, '')
      end
    end

    def model_class
      @model_class ||= self.model.to_s.camelize.constantize
    end

    def immutable_method(method_name)
      self.class_eval <<-END_EVAL, __FILE__, __LINE__ + 1
        def #{method_name}_with_immutation(*args, &block)
          self.dup.tap do |clone|
            clone.#{method_name}_without_immutation(*args, &block)
          end
        end
      END_EVAL
      self.alias_method_chain method_name, :immutation
    end

    def respond(options={})
      raise ArgumentError.new(":to option should be a Regexp") unless options[:to].is_a?(Regexp)
      raise ArgumentError.new(":with option is mandatory") unless options[:with].present?
      self.dynamic_methods ||= []
      self.dynamic_methods += [[options[:to], options[:with]]]
    end

    def allow_scopes(*scopes)
      @allowed_scopes = scopes
      scopes.each do |scope_name|
        self.class_eval <<-END_EVAL, __FILE__, __LINE__ + 1
          def #{scope_name}(*args)
            @scope = scope.public_send(:#{scope_name}, *args)
          end
        END_EVAL
        self.immutable_method(scope_name)
      end
    end

  end

  delegate :model_class, :to => 'self.class'
  
  respond :to => /limited_to_(\d+)/, :with => :limit_to

  def initialize(base_scope=nil, context=nil)
    @scope = base_scope
    @context ||= context
  end

  def all
    self
  end

  def each(&block)
    scope.each(&block)
  end

  def before_method(method_name, *args)
    self.class.dynamic_methods.each do |pattern, method|
      if match_data = pattern.match(method_name)
        return self.send(method, *match_data[1..-1])
      end
    end
    raise NoMethodError.new("undefined method `#{method_name}' for #{self.inspect}")
  end

  delegate :to_a, to: :each
  delegate *(Array.public_instance_methods - self.public_instance_methods), to: :to_a

  protected

  def limit_to(size)
    @scope = scope.limit(size.to_i)
  end
  immutable_method :limit_to

  def scope
    @scope ||= default_scope
  end

  def default_scope
    model_class
  end

  def context
    @context
  end

  private
  
  if Rails.env.test? # Just for cleaner and simpler specs
    def method_missing(name, *args, &block)
      before_method(name.to_s)
    end
  end
end
