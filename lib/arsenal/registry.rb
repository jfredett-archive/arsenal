module Arsenal
  class Registry
    extend Forwardable
    include Enumerable

    delegate [:[], :has_key?, :each] => :registry

    def initialize(registry = {}, &block)
      @mapper = block
      @original_registry = registry
      clear!(registry)
    end

    def register(registrant)
      registry[registrant] = mapper.call(registrant)
    end
    alias register! register

    def clear!(registry = nil)
      @registry = registry || @original_registry
      self
    end

    private

    attr_reader :registry, :mapper
  end

  class ModelRegistry < Registry
    alias have_model? has_key?

    def initialize(registry = {})
      super(registry) do |model|
        { nil: model::Nil,
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

    private 

    #@private
    def retrieve_class(model, klass)
      model = model.class unless model.is_a?(Class)
      model = model.send(:__associated_arsenal_model) if model.respond_to?(:__associated_arsenal_model)
      return unless have_model?(model)
      self[model][klass] 
    end
  end
end
