require "arsenal/version"
require 'singleton'

require 'initializer'

require 'singleton'

module Arsenal
  extend ActiveSupport::Concern  

  def self.create_nil_method!(base) 
    Kernel.send(:define_method, "nil_#{base.to_s.downcase}") do
      base::Nil.instance
    end
  end

  included do
    class self::Repository 
      include Arsenal::RepositoryMethods
    end

    class self::Nil 
      include Arsenal::NilMethods
    end

    class self::Persisted < self
      include Arsenal::PersistedMethods
    end

    class self::Collection < Array
    end

    Arsenal.create_nil_method!(self)
  end


  module NilMethods
    extend ActiveSupport::Concern

    included do
      include Singleton
    end

    module InstanceMethods
      def nil?       ; true  ; end
      def persisted? ; false ; end
      def savable?   ; false ; end
    end
  end

  module PersistedMethods
    extend ActiveSupport::Concern

    module InstanceMethods
      def persisted? 
        true
      end

    end
  end

  module ClassMethods

  end

  module InstanceMethods
    def persisted? 
      false
    end
    
    def savable? 
      true
    end
  end
end
