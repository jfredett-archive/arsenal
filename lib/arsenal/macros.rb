module Arsenal
  module Macros 
    def id(method)
      attribute :id, method: method.to_sym, required: true 
    end

    def attribute(method, opts = {})
      attributes << Attribute.new(method, opts)
    end

    def attributes
      superclass_attrs = superclass.attributes if superclass.respond_to? :attributes
      @__attrs ||= AttributeCollection.new + superclass_attrs
    end
  end
end
