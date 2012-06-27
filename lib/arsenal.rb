require "arsenal/version"
require 'singleton'

require 'initializer'

require 'singleton'

module Arsenal
  extend ActiveSupport::Concern  

  included do
    class self::Repository 
      class << self
        def save

        end

        def find

        end

        def destroy

        end
      end
    end

    class self::Nil 
      include Singleton
      def nil? ; true ; end

    end

    class self::Persisted < self

    end

    class self::Collection < Array
    end
  end
end
