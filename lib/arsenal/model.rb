module Arsenal
  # The Arsenal Model represents an un-persisted domain object. This module
  # contains Arsenal-provided instance methods for a model.
  module Model
    # When instantiating the model, throw a {Arsenal::IdentifierNotGivenError}
    # unless the `id` macro has been called in the class context. This ensures
    # that we can always persist and retrieve these objects, since we need a
    # primary key to do so.
    #
    # Further, it calls the instance method #build with the hash of attributes
    # as it's argument. This must be overridden by the user to load those
    # attributes into the model as they see fit.
    #
    # @param attrs [Hash] the attributes to be assigned to this instance of the
    #   model.
    #
    # @see Arsenal::IdentifierNotGivenError
    # @see Arsenal::Model #build
    def initialize(attrs = {})
      raise Arsenal::IdentifierNotGivenError unless id.present?
      build(attrs)
      # Finally, it calls the parent initialization method with no arguments
      # ideally, this would be part of the normal #initialize method, but ruby
      # is a bit finicky around this bit.
      super()
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
    #
    # @deprecated
    def drivers
      self.class.drivers
    end

    # The model is not a collection of other models
    #
    # @return [Boolean] always false
    def collection?
      false
    end

    # Returns an {Arsenal::AttributeCollection} of all the attributes are to be
    # serialized to the given driver.
    #
    # @param driver [Arsenal::Driver] the driver to retrieve the attributes for
    #
    # @return [Hash] A hash of attribute name and associated value
    def attributes_for(driver)
      AttributeCollection.new(
        full_attributes.select { |a| a.driver == driver || a.name == :id }
      ).to_hash(self)
    end

    private

    # This method should be overridden. It allows you to set all of the
    # attributes of your model at initialization time.
    #
    # @param attrs [Hash] the attributes to be assigned to this instance of the
    #   model.
    def build(attrs)
      # Implement #build
    end

    # Get the AttributeCollection of attributes for this model
    #
    # @return [Arsenal::AttributeCollection] the collection of attributes for
    #  the model.
    def full_attributes
      self.class.attributes
    end
  end
end
