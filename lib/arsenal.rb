require "arsenal/version"
require 'singleton'

require 'initializer'

require 'singleton'

module Arsenal
  extend ActiveSupport::Concern  


  included do
    extend Forwardable

    base = self

    base::Repository = Class.new do
      include Arsenal::Repository
    end

    base::Nil = Class.new do
      include Arsenal::Nil
    end
    base::Nil.nil_model = base

    base::Persisted = Class.new(base) do
      include Arsenal::Persisted
    end

    base::Collection = Class.new(Array) do
      include Arsenal::Collection
    end

    Arsenal.create_nil_method!(base)
  end

  module ClassMethods
    def id(method)
      attribute :id, method: method.to_sym, required: true 
    end

    def attribute(method, opts = {})
      attributes << Attribute.new(method, opts)
    end

    def attributes
      superclass_attrs = superclass.attributes if superclass.respond_to? :attributes
      @__attrs ||= AttributeCollection.new + superclass_attrs
    end
  end

  module InstanceMethods
    def initialize
      raise Arsenal::IdentifierNotGivenError unless id.present?
      super
    end

    def persisted? 
      false
    end
    
    def savable? 
      true
    end

    def id
      attributes[:id] 
    end

    def attributes
      self.class.attributes.to_hash(self)
    end
  end

  private 

  def self.create_nil_method!(base) 
    Kernel.send(:define_method, "nil_#{base.to_s.downcase}") do
      base::Nil.instance
    end
  end
end
