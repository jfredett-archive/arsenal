module Arsenal
  # A collection of attributes for a model, provides basic management for sets
  # of attributes.
  #
  # @see Arsenal::Attribute
  class AttributeCollection < Set
    # Create a new collection of attributes
    #
    # @param arr [Array] a list of attributes
    #
    # @return [Arsenal::AttributeCollection] a new collection for the given
    #  attributes
    def initialize(arr = [])
      super(arr)
    end

    # The set of attribute names
    #
    # @return an array of attribute names
    def keys
      map { |a| a.name }
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
      assert_quacks_like_attribute attr
      super
    end
    alias push <<

    # Access a given attribute by name.
    #
    # @param key [Symbol] the name of the attribute you're looking for.
    #
    # @return [Arsenal::Attribute, nil] Returns an attribute if one is found,
    #  nil otherwise
    def [](key)
      find { |e| e.name == key }
    end

    # Given a model upon which to act, return a hash from attribute name to
    # attribute value for that object.
    #
    # @param obj [Arsenal::Model] An object which implements all of the attribute methods
    #
    # @return [Hash] a hash containing all of the attribute names as keys,
    #  and their corresponding values as values
    def to_hash(obj)
      each.with_object({}) do |e,a|
        a[e.name] = e.value(obj)
      end
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
      other.each { |attr| assert_quacks_like_attribute attr }
      super
    end

    # Wraps the [Set] implementation of #select to return a AttributeCollection
    def select
      AttributeCollection.new(super)
    end


    # Returns all the attribues which serialize to a given driver.
    #
    # @param driver [Arsenal::Driver] the driver object for which we will return
    # attributes
    #
    # @return [Arsenal::AttributeCollection] the set of attributes which use the
    # given driver
    #
    # @todo Presently, there is no {Arsenal::Driver} class, so this
    # documentation is a lie.
    def for(driver)
      select { |a| a.name == :id || a.driver == driver }
    end

    private

    def assert_quacks_like_attribute(attr)
      raise ArgumentError unless attr.respond_to? :name and attr.respond_to? :default
    end

  end
end
