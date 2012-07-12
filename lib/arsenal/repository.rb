module Arsenal
  # The Repository module contains methods for the Arsenal-model's associated
  # repository. In particular, it interacts with drivers to serialize
  # Arsenal-models into memory.
  module Repository
    def save(model)
      return false         unless model.savable?
      return update(model) if model.persisted?
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
