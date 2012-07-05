module Arsenal
  module Nil
    extend ActiveSupport::Concern

    included do
      include Singleton
    end

    module InstanceMethods
      def nil?       ; true  ; end
      def persisted? ; false ; end
      def savable?   ; false ; end
      def id         ; nil   ; end

      def attributes ; {id: nil}    ; end

      def nil_model
        self.class.nil_model
      end

      def method_missing(method, *args, &block) 
        super if respond_to? method

        if attr = nil_model.attributes[method]
          return attr.default
        end

        super
      end
    end

    module ClassMethods
      attr_accessor :nil_model
    end
  end
end
