module Arsenal
  # The Arsenal Model represents an un-persisted domain object. This module
  # contains Arsenal-provided instance methods for a model.
  module Model 
    # When instantiating the model, throw a {Arsenal::IdentifierNotGivenError} 
    # unless the `id` macro has been called in the class context. This ensures
    # that we can always persist and retrieve these objects, since we need a
    # primary key to do so.
    #
    # @see Arsenal::IdentifierNotGivenError
    def initialize
      raise Arsenal::IdentifierNotGivenError unless id.present?
      super
    end

    # Indicates whether the given model is persisted to the datastores.
    #
    # @see Arsenal::Persisted Arsenal::Persisted#persisted?
    # @see Arsenal::Nil Arsenal::Nil#persisted?
    # @see Arsenal::Collection Arsenal::Collection#persisted?
    #
    # @return [Boolean] true if the object is persisted, false otherwise
    def persisted? 
      false
    end
    
    # Indicates whether the given model can be persisted to the datastores.
    #
    # @see Arsenal::Persisted Arsenal::Persisted#persisted?
    # @see Arsenal::Nil Arsenal::Nil#persisted?
    # @see Arsenal::Collection Arsenal::Collection#persisted?
    #
    # @return [Boolean] true if the object can be persisted, false otherwise
    def savable? 
      true
    end

    # A unique idenitfier attribute for the model
    #
    # @see Arsenal::Attribute Arsenal::Attribute
    #
    # @return [ Arsenal::Attribute ] the identifier attribute for the model
    def id
      attributes[:id] 
    end

    # A hash of all the attributes and their values associated with this model
    #
    # @return [Hash] All the attributes and their associated values for the
    #  model instance
    def attributes
      full_attributes.to_hash(self)
    end

    # Returns the list of all drivers the model's attributes use
    #
    # @return [Array<Symbol>] The list of the names of all the drivers used by
    #  the attributes.
    def drivers
      full_attributes.map(&:driver).uniq.reject(&:nil?)
    end

    private 

    # Get the AttributeCollection of attributes for this model
    #
    # @return [Arsenal::AttributeCollection] the collection of attributes for
    #  the model.
    def full_attributes 
      self.class.attributes
    end
  end
end
