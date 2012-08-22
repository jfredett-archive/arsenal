module Arsenal
  # A registry object, accepts a proc on creation, which is called on the
  # argument of #register whever it's called, the result is stored in a hash
  # which can be looked up via #[]. Generally acts as a Hash.
  class Registry
    extend Forwardable
    include Enumerable

    delegate [:[], :has_key?, :each, :empty?] => :registry

    def initialize(registry = Hash.new({}), &block)
      @mapper = block
      @original_registry = registry.dup
      clear!(registry)
    end

    # register a new entry in the registry
    #
    # @param registrant [Object] the object to register
    #
    # @return [Arsenal::Registry] the registry object, to allow chaining
    def register(registrant)
      registry[registrant] = mapper.call(registrant)
      self
    end
    alias register! register

    # clear the registry of all objects, optionally initializing it to the given
    # value.
    #
    # @param registry [Object] an initial state for the registry
    #
    # @return [Arsenal::Registry] the cleared registry object, to allow chaining
    def clear!(registry = nil)
      @registry = registry || @original_registry
      self
    end

    private

    attr_reader :registry, :mapper
  end

  # A registry for Arsenal Models, contains arsenal-specific methods for
  # retrieving generated classes.
  #
  # NB. In this class, [Arsenal::Model] in the parameters section means the
  # original including class, or any of the Arsenal-generated classes.
  class ModelRegistry < Registry
    alias have_model? has_key?

    def initialize
      super do |model|
        { model: model,
          nil: model::Nil.instance,
          persisted: model::Persisted,
          collection: model::Collection,
          repository: model::Repository }
      end
    end

    # The collection model for a given arsenal model
    #
    # @param model [Arsenal::Model] the model to retrieve the collection class for
    #
    # @return [Arsenal::Collection] the collection class for the model
    def collection_for(model)
      retrieve_class(model, :collection)
    end

    # The persisted model for a given arsenal model
    #
    # @param model [Arsenal::Model] the model to retrieve the persisted class for
    #
    # @return [Arsenal::Persisted] the persisted class for the model
    def persisted_for(model)
      retrieve_class(model, :persisted)
    end

    # The nil model for a given arsenal model
    #
    # @param model [Arsenal::Model] the model to retrieve the nil class for
    #
    # @return [Arsenal::Nil] the nil class for the model
    def nil_for(model)
      retrieve_class(model, :nil)
    end

    # The repository model for a given arsenal model
    #
    # @param model [Arsenal::Model] the model to retrieve the repository class for
    #
    # @return [Arsenal::Repository] the repository class for the model
    def repository_for(model)
      retrieve_class(model, :repository)
    end

    # The Arsenal model proper for a given arsenal model
    #
    # NB. This is used primarily by the generated classes to get at the
    # including class
    #
    # @param model [Arsenal::Model] the model to retrieve the repository class for
    #
    # @return [Arsenal::Model] the repository class for the model
    def model_for(model)
      retrieve_class(model, :model)
    end

    private 

    #@private
    def retrieve_class(model, klass)
      #unwrap the given model if it's an instance/generated model
      model = model.class unless model.is_a? Class
      model = model.__associated_arsenal_model if model.respond_to? :__associated_arsenal_model
      return self[model][klass] unless model.nil? #or self[model].nil?
    end

  end
end
