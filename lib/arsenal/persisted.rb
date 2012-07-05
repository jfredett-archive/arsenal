module Arsenal
  module Persisted
    extend ActiveSupport::Concern

    module InstanceMethods
      def persisted? 
        true
      end
    end
  end
end
