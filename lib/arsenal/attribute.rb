module Arsenal
  class Attribute
    attr_reader :name, :default

    def initialize(name, opts = {})
      @name = name
      @default = opts[:default]
    end
  end

  class AttributeCollection
    def initialize(arr = [])
      @attrs = arr
    end

    def <<(attr)
      raise ArgumentError unless attr.respond_to? :name and attr.respond_to? :default
      @attrs << attr
      self
    end

    def [](key)
      @attrs.each do |a|
        return a if a.name == key
      end
      nil
    end
  end
end
