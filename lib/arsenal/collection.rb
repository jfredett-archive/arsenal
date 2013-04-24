module Arsenal
  # The collection module contains instance methods for the Arsenal-model
  # collection class.
  #
  # By default, the collection-class for a model delegates all methods to it's
  # components. When the call matches `(all|any)_<predicate>` (where
  # `<predicate>` is any method ending in `?` and returning a Boolean), the
  # result will be a Boolean which indicates if `all` (resp: `any`) of the
  # elements assert the given predicate.
  #
  # In every case, this is overridden by a manually defined method on the class
  # itself. So that if you define `all_foo?`, that method will be called instead
  # of executing a `all?(&:foo?)` -- as would normally be the case.
  module Collection
    # A collection is savable when it's elements are all savable.
    #
    # @see Arsenal::Persisted Arsenal::Persisted#savable?
    # @see Arsenal::Nil Arsenal::Nil#savable?
    # @see Arsenal::Collection Arsenal::Model#savable?
    #
    # @return [Boolean] true if all the elements assert `#savable?`, false
    #  otherwise
    def savable?
      all_savable?
    end

    # A collection is persisted when it's elements are all persisted.
    #
    # @see Arsenal::Persisted Arsenal::Persisted#persisted?
    # @see Arsenal::Nil Arsenal::Nil#persisted?
    # @see Arsenal::Collection Arsenal::Model#persisted?
    #
    # @return [Boolean] true if all the elements assert `#persisted?`, false
    #  otherwise
    def persisted?
      all_persisted?
    end

    # The model is a collection of other models
    #
    # @return [Boolean] always true
    def collection?
      true
    end

    # @private
    def method_missing(method, *args, &block)
      super if respond_to? method

      iterator = :each
      predicate = method

      if method =~ /(any|all)_(.*\?)/
        iterator = "#{$1}?".to_sym
        predicate = $2.to_sym
      end

      send(iterator) { |e| e.send(predicate, *args, &block) }
    end
  end
end
