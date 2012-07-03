require "arsenal/version"
require 'singleton'

require 'initializer'

require 'singleton'

module Arsenal
  extend ActiveSupport::Concern  

  def self.create_nil_method!(base) 
    Kernel.send(:define_method, "nil_#{base.to_s.downcase}") do
      base::Nil.instance
    end
  end

  included do
    extend Forwardable

    base = self

    base::Repository = Class.new do
      include Arsenal::RepositoryMethods
    end

    base::Nil = Class.new do
      include Arsenal::NilMethods
    end
    base::Nil.nil_model = base

    base::Persisted = Class.new(base) do
      include Arsenal::PersistedMethods
    end

    base::Collection = Class.new(Array) do
      include Arsenal::CollectionMethods
    end

    Arsenal.create_nil_method!(base)
  end

  module ClassMethods
    attr_reader :__identifier_method

    def id(method)
      @__identifier_method = method.to_sym
    end

    def attribute(method, opts = {})
      attributes << Attribute.new(method, opts)
    end

    def attributes
      superclass_attrs = superclass.attributes if superclass.respond_to? :attributes
      @__attrs ||= AttributeCollection.new + superclass_attrs
    end
    end
  end

  module InstanceMethods
    def persisted? 
      false
    end
    
    def savable? 
      true
    end

    def id
      send(self.class.__identifier_method) 
    end

    def attributes
      self.class.attributes.to_hash(self)
    end
  end
end
