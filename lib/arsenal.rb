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

  private 

  def self.create_nil_method!(base) 
    Kernel.send(:define_method, "nil_#{base.to_s.downcase}") do
      base::Nil.instance
    end
  end

  module ClassMethods
    include Arsenal::Macros
  end

  module InstanceMethods
    include Arsenal::Model
  end
end
