module Arsenal
  module Collection
    extend ActiveSupport::Concern

    module InstanceMethods
      def savable?
        all_savable?
      end

      def persisted?
        all_persisted?
      end

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
end
