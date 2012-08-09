require "arsenal/version"
require 'singleton'

require 'initializer'

require 'singleton'

# Arsenal is a Repository-pattern focused ORM which supports lightweight
# database drivers and polyglot persistence-by-default. It is unobtrusive,
# module based, and easy to use.
module Arsenal
  extend ActiveSupport::Concern  
  extend Forwardable
  class << self
    extend Forwardable 
  end

  included do
    extend Forwardable

    base = self

    base::Repository = Class.new do
      extend Arsenal::Repository
    end
    Arsenal.create_associated_model_method!(base::Repository, base)

    base::Nil = Class.new do
      include Arsenal::Nil
    end
    base::Nil.nil_model = base
    Arsenal.create_associated_model_method!(base::Nil, base)

    base::Persisted = Class.new(base) do
      include Arsenal::Persisted
    end
    Arsenal.create_associated_model_method!(base::Persisted, base)

    base::Collection = Class.new(Array) do
      include Arsenal::Collection
    end
    Arsenal.create_associated_model_method!(base::Collection, base)

    Arsenal.create_nil_method!(base)
    Arsenal.register!(base)  

    extend Arsenal::Macros
    include Arsenal::Model
  end

  class << self
    delegate [:collection_for, :persisted_for] => :registry
  end

  private 

  class << self
    delegate [:register!] => :registry

    # the hash of all models which are wired up as arsenal models, and references
    # to each of their arsenal-defined classes (including the model itself)
    #
    # @return [Arsenal::Registry] all of the Arsenal Models and their Arsenal-defined classes
    def registry
      @registry ||= Arsenal::ModelRegistry.new 
    end

    #@private
    def create_nil_method!(base) 
      Kernel.send(:define_method, "nil_#{base.to_s.downcase}") do
        base::Nil.instance
      end
    end

    #@private
    def create_associated_model_method!(klass, associated_model)
      klass.send(:define_singleton_method, :__associated_arsenal_model) do
        associated_model
      end
    end
  end
end
