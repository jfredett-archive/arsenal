module Arsenal
  # The Persisted module contains instance methods for the Perisited-model
  # subclass of an arsenal model. 
  module Persisted
    # By definition, a Persisted model is persisted.
    #
    # @return [Boolean] true
    def persisted? 
      true
    end
  end
end
