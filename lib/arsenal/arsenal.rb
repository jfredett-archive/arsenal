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
      include Arsenal::CollectionMethods
    end

    Arsenal.create_nil_method!(self)
  end

  module ClassMethods
    attr_reader :__identifier_method

    def id(method)
      @__identifier_method = method.to_sym
    end

    def attribute

    end
  end

  module InstanceMethods
    def persisted? 
      false
    end
    
    def savable? 
      true
    end

    def id
      send(self.class.__identifier_method) 
    end

    def attributes
      { id: id }
    end
  end
end
