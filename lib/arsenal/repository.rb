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
        when model.persisted?
          update(model)
        when model.collection?
          return proxy(model)  
        else
          write(model) 
      end

      persist(model) if ok
    end

    # todo: implement
    def find
    end

    # todo: implement
    def destroy
    end

    private

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
    end

    def write(model)
      model.drivers.all? do |driver|
        ok = driver.write(model.attributes_for(driver))
      end
    end
  end
end
