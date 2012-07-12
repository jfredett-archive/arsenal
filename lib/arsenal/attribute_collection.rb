module Arsenal
  # A collection of attributes for a model, provides basic management for sets
  # of attributes.
  #
  # @see Arsenal::Attribute
  class AttributeCollection
    include Enumerable

    # Create a new collection of attributes
    #
    # @param arr [Array] a list of attributes
    #
    # @return [Arsenal::AttributeCollection] a new collection for the given
    #  attributes
    def initialize(arr = [])
      @attrs = arr
    end

    # The set of attribute names
    #
    # @return an array of attribute names
    def keys
      @attrs.map { |a| a.name } 
    end

    # Add a new attribute to the collection
    #
    # @param attr [#name,#default] A new attribute-like object which is to be added
    #  to the collection
    #  
    # @return [Arsenal::AttributeCollection] the receiving AttributeCollection,
    #  which now has the new attribute added.
    #
    # @raise [ArgumentError] if the attribute-like object does not implement
    #  the required messages
    def <<(attr)
      raise ArgumentError unless attr.respond_to? :name and attr.respond_to? :default
      @attrs << attr
      self
    end
    alias push <<

    # Access a given attribute by name.
    #
    # @param key [Symbol] the name of the attribute you're looking for.
    #
    # @return [Arsenal::Attribute, nil] Returns an attribute if one is found,
    #  nil otherwise
    def [](key)
      @attrs.each do |a|
        return a if a.name == key
      end
      nil
    end

    # Given a model upon which to act, return a hash from attribute name to
    # attribute value for that object.
    #
    # @param obj [Arsenal::Model] An object which implements all of the attribute methods
    #
    # @return [Hash] a hash containing all of the attribute names as keys, 
    #  and their corresponding values as values
    def to_hash(obj)
      @attrs.each.with_object({}) do |e,a|
        a[e.name] = e.value(obj)
      end
    end

    # Execute the given block over each attribute
    #
    # @param block [#call] A block to execute on each attribute
    #
    # @return [Array] the list of attributes
    #
    # @todo bug here, should it return the AttributeCollection?
    def each(&block)
      @attrs.each(&block)
    end

    # Concatenate two AttributeCollections together.
    #
    # @param other [Arsenal::AttributeCollection] another attribute collection
    #  to join with this one
    #
    # @return [Arsenal::AttributeCollection] a new attribute collection
    #  containing the attributes from both collections
    def +(other)
      return self.dup if other.nil?

      coll = AttributeCollection.new
      each       { |attr| coll << attr } 
      other.each { |attr| coll << attr } 
      return coll
    end

    # Equality of AttributeCollections is determined by equal attribute-sets
    #
    # @param other [Arsenal::AttributeCollection] another attribute collection
    #  to compare for equality
    #
    # @return [Boolean] true if the two collections have the same attributes,
    #  false otherwise
    def ==(other)
      attrs = @attrs.dup
      other.each do |attr|
        return false unless attrs.include?(attr)
        attrs.delete(attr)
      end
      attrs.empty? 
    end

  end
end
