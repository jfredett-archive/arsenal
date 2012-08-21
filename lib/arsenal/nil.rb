module Arsenal
  # The NilModel module contains instance methods for the Arsenal-model's
  # Nil-class implementation.
  #
  # The Nil-class will also respond to the parent model's attributes, by name,
  # as methods, and return the default value associated with them, if there is
  # no default value, then `nil` is returned.
  module NilModel
    
    # The model should act-as-nil, so this is defined as true.
    #
    # @return [Boolean] always true
    def nil?       ; true  ; end

    def collection? ; false ; end

    # This model is never persisted
    #
    # @return [Boolean] always false
    def persisted? ; false ; end
    
    # This model is not savable
    #
    # @return [Boolean] always false
    def savable?   ; false ; end

    # This model has no id.
    #
    # @return nil
    def id         ; nil   ; end

    # It returns the set of attributes corresponding to the set of default
    # attributes on it's associated Model class. For each attribute which does
    # not have a set default, it returns nil.
    #
    # @todo: Implement
    #
    # @return [Hash] All the attributes and their associated values for the
    #  model instance
    def attributes ; {id: nil}    ; end

   
    # @private
    def method_missing(method, *args, &block) 
      return super if respond_to? method

      if attr = Arsenal.model_for(self).attributes[method]
        return attr.default
      end

      super
    end
  end

  # @private
  module Nil
    extend ActiveSupport::Concern

    included do
      include Singleton
    end

    module InstanceMethods
      include Arsenal::NilModel
    end
  end
end
