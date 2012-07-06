module Arsenal

  module Macros 
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

  module Model 

    def initialize
      raise Arsenal::IdentifierNotGivenError unless id.present?
      super
    end

    # Indicates whether the given model is persisted to the datastores.
    #
    # @see Arsenal::Persisted#persisted?
    # @see Nil#persisted?
    # @see Collection#persisted?
    #
    # @returns [Boolean] true if the object is persisted, false otherwise
    def persisted? 
      false
    end
    
    # Indicates whether the given model can be persisted to the datastores.
    #
    # @see Persisted#persisted?
    # @see Nil#persisted?
    # @see Collection#persisted?
    #
    # @returns [Boolean] true if the object can be persisted, false otherwise
    def savable? 
      true
    end


    # A unique idenitfier attribute for the model
    #
    # @returns [Arsenal::Attribute] the identifier attribute for the model
    def id
      attributes[:id] 
    end

    # A hash of all the attributes and their values associated with this model
    #
    # @returns [Hash] All the attributes and their associated values for the
    # model instance
    def attributes
      self.class.attributes.to_hash(self)
    end
  end

end
