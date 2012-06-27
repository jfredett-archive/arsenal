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

    def attribute

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
      { id: id }
    end
  end
end
