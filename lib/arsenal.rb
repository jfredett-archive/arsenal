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
    Arsenal.register!(base)  
  end

  # The collection model for a given arsenal model
  #
  # @param model [Arsenal::Model] the model to retrieve the collection class for
  #
  # @return [Arsenal::Collection] the collection class for the model
  def self.collection_for(model)
    retrieve_class(model, :collection)
  end

  # The persisted model for a given arsenal model
  #
  # @param model [Arsenal::Model] the model to retrieve the persisted class for
  #
  # @return [Arsenal::Collection] the persisted class for the model
  def self.persisted_for(model)
    retrieve_class(model, :persisted)
  end

  private 

  #@private
  def self.retrieve_class(model, klass)
    model = model.class unless model.is_a?(Class)
    return unless have_model?(model)
    registry[model][klass] 
  end

  # Check if there has been an Arsenal Model created for the given model.
  #
  # @param model [Class] the model to check
  #
  # @return true if Arsenal has wired up the given class as an Arsenal Model
  def self.have_model?(model)
    registry.has_key?(model)
  end

  # register a new class as having been wired up by arsenal as an Arsenal Model
  #
  # @param model [Class] the model class to register
  def self.register!(model)
    registry[model] = { 
           model: model,
             nil: model::Nil,
       persisted: model::Persisted,
      collection: model::Collection,
      repository: model::Repository
    }
    nil
  end

  # the hash of all models which are wired up as arsenal models, and references
  # to each of their arsenal-defined classes (including the model itself)
  #
  # @return [Hash] all of the Arsenal Models and their Arsenal-defined classes
  def self.registry
    @registry ||= {}
  end

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
