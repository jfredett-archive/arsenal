module Arsenal
  module NilMethods
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
    end
  end
end
