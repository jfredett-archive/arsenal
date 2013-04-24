module Arsenal
  # The Repository module contains methods for the Arsenal-model's associated
  # repository. In particular, it interacts with drivers to serialize
  # Arsenal-models into memory.
  module Repository
    # Serialize the given model to the backends it uses.
    #
    # **DOES NOT** necessarily operate transactionally. If you are serializing
    # to multiple backends, you _may lose/corrupt data_ if something goes wrong
    # with your hardware. _Always_ have a canonical, transactionally written
    # serialization of each model, use transactional drivers, and _be careful_.
    #
    # @param model [Arsenal::Model] the model to serialize.
    #
    # @return [Boolean, Arsenal::Persisted] returns a persisted version of the model
    #  (or a collection of persisted models in the case of a collection) if the save
    #  was 100% successful, false otherwise.
    def save(model)
      return false unless model.savable?

      ok = case
        when model.collection?
          return proxy(model)
        when model.persisted?
          update(model)
        else
          write(model)
      end

      persist(model) if ok
    end

    # Find the set of models which match the given criterion
    #
    # @param criterion [Arsenal::Model, Arsenal::Persisted, Arsenal::Nil, Arsenal::Collection, Hash]
    #   The criterion to search for
    #
    # Depending on the type of criterion, different things are sent to the
    # various drivers
    #
    # * Hash
    #
    # If the criterion is an empty Hash, nothing is sent, and the Arsenal::Nil
    # model is returned. If it is a nonempty has, it, and the index name for
    # this model, is sent to each of the drivers for this model.
    #
    # * Collection
    #
    # The #find call is delegated to each member of the collection, and a new
    # collection is returned with the results.
    #
    # * Regular Model
    #
    # #find is called with the hash of attributes from the model
    #
    # * Persisted Model
    #
    # #find is called with a hash containing the id of the model.
    #
    # # Nil Model
    #
    # the nil model is returned, no calls to the drivers are made.
    #
    # @return [Arsenal::Collection, Arsenal::Nil] The collection of models found
    #   in the data store, the collection should be flattened, but items in it may
    #   be duplicated (in the case of a #find called on a collection)
    #
    def find(criterion)
      binding.pry
      ok = case
        when criterion.is_a?(Hash)
          binding.pry
          return Arsenal.nil_for(self) if criterion.empty?
          results = drivers.map { |d| d.find(index_name, criterion) }.reject(&:nil?)
        when criterion.collection?
          binding.pry
          criterion.map { |e| find(e) }
        when criterion.persisted?
          binding.pry
          find(id: criterion.id)
        when criterion.nil?
          find(id: criterion.id)
          return Arsenal.nil_for(self)
        else #is a regular model
          binding.pry
          find(criterion.attributes)
      end
    end

    # todo: implement
    def destroy
      ok = case
        when Hash
        when model.collection?
        when model.persisted?
        when model.nil?
        else
      end
      return unless ok
    end

    private

    def drivers
      @drivers ||= Arsenal.model_for(self).drivers
    end

    def persist(model)
      Arsenal.persisted_for(model).
              new(model.attributes)
    end

    # proxy the Repository.save(model) across each element of the collection
    def proxy(model)
      model.map! do |elt, coll|
        save(elt).tap { |result| return false unless result }
      end
    end

    def update(model)
      drivers.all? do |driver|
        driver.update(model.attributes_for(driver))
      end
    end

    def write(model)
      model.drivers.all? do |driver|
        driver.write(model.attributes_for(driver))
      end
    end

    def index_name
      @__index_name ||= Arsenal.model_for(self).to_s.downcase.pluralize
    end
  end
end
