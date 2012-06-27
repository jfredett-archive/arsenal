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

      def attributes ; {}    ; end
    end
  end
end
