require "arsenal/version"
require 'singleton'

require 'initializer'

require 'singleton'

# Arsenal is a Repository-pattern focused ORM which supports lightweight
# database drivers and polyglot persistence-by-default. It is unobtrusive,
# module based, and easy to use.
module Arsenal
  extend ActiveSupport::Concern  

  included do
    extend Forwardable

    base = self

    base::Repository = Class.new do
      extend Arsenal::Repository
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

  #@private
  def self.create_nil_method!(base) 
    Kernel.send(:define_method, "nil_#{base.to_s.downcase}") do
      base::Nil.instance
    end
  end

  # @private
  module ClassMethods
    include Arsenal::Macros
  end

  # @private
  module InstanceMethods
    include Arsenal::Model
  end
end
