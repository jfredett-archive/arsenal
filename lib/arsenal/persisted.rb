module Arsenal
  module PersistedMethods
    extend ActiveSupport::Concern

    module InstanceMethods
      def persisted? 
        true
      end
    end
  end
end
