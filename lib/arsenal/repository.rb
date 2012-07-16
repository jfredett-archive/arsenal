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
    # @return [Boolean] true if the save was 100% successful, false otherwise.
    def save(model)
      return false         unless model.savable?
      return update(model) if     model.persisted?
      return write(model) 
    end

    # todo: implement
    def find
    end

    # todo: implement
    def destroy
    end

    private

    def update(model)
    end

    def write(model)
      model.drivers.all? do |driver|
        driver.write(model.attributes_for(driver))
      end
    end
  end
end
