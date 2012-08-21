require "arsenal/version"
require 'initializer'

# Arsenal is a Repository-pattern focused ORM which supports lightweight
# database drivers and polyglot persistence by default. It is unobtrusive,
# module based, and easy to use.
module Arsenal
  extend ActiveSupport::Concern  

  included do
    extend Forwardable
    extend Arsenal::Macros

    include Arsenal::Model

    self::Repository    = Class.new        { extend  Arsenal::Repository }
    self::Persisted     = Class.new(self)  { include Arsenal::Persisted  }
    self::Collection    = Class.new(Array) { include Arsenal::Collection }
    self::Nil           = Class.new        { include Arsenal::Nil        }

    Arsenal.create_associated_model_method!(self::Repository, self)
    Arsenal.create_associated_model_method!(self::Nil, self)
    Arsenal.create_associated_model_method!(self::Persisted, self)
    Arsenal.create_associated_model_method!(self::Collection, self)

    Arsenal.create_nil_method!(self)
    
    Arsenal.register!(self)  
  end

  class << self
    extend Forwardable 
    delegate [:register!, :nil_for, :model_for, :repository_for, :collection_for, :persisted_for] => :registry

    # The registry of all models which are wired up as arsenal models, and
    # references to each of their arsenal-defined classes (including the model
    # itself)
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
