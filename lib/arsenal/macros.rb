module Arsenal
  # The Macros module contains class macros for an Arsenal Model.
  module Macros 
    # Sets a primary key for the model
    #
    # @param method [Symbol] the name of the method that will act as a primary
    #  key for the model.
    def id(method)
      attribute :id, method: method.to_sym, required: true 
    end

    # Sets an arbitrary attribute on the class
    #
    # Accepts the following options:
    #
    # * `required`
    #
    #   Accepts a `Boolean` or anything that implements `#call`, this is used to
    #   determine if the attribute is a required attribute, which would prevent
    #   saving if it is not provided (eg, if it is nil).
    #
    # @todo this depends on implementing saving/loading first.
    #
    # * `default`
    #
    #   Accepts a value to be used as the 'default' value of this parameter in
    #   the context of the nil-class for this model. {Arsenal::NilModel Arsenal::Nil}
    #
    # * `method` 
    #
    #   Accepts a symbol which indicates that the parameter should be named one
    #   thing, but accessed via a different method. Used primarily by the
    #   implementation of {Arsenal::Macros #id}
    #
    # @param method [Symbol] the name of the method which should be populated by 
    #  the attribute.
    # @param opts [Hash] the set of options, described above, for the hash
    #
    # @todo automatically generate an attr_accessor? (but allow for # override?)
    def attribute(method, opts = {})
      attributes << Attribute.new(method, opts)
    end

    # The set of attributes for the given model
    #
    # @return [Arsenal::AttributeCollection] The set of attributes for the model as attribute objects.
    def attributes
      superclass_attrs = superclass.attributes if superclass.respond_to? :attributes
      @__attrs ||= AttributeCollection.new + superclass_attrs
    end


    # Returns the list of all drivers the model's attributes use
    #
    # @return [Array<Symbol>] The list of the names of all the drivers used by
    #  the attributes.
    def drivers
      attributes.map(&:driver).uniq.reject(&:nil?)
    end
  end
end
