module Arsenal
  class Attribute
    attr_reader :name, :default

    def value(instance)
      return @default unless instance.respond_to?(@name)
      instance.send(@name)  
    end

    def has_default?
      @default.present?
    end

    def required? 
      !!@required
    end

    def initialize(name, opts = {})
      @name = name
      @default = opts[:default]
      @required = opts[:required]
    end
  end

  class AttributeCollection
    def initialize(arr = [])
      @attrs = arr
    end

    def keys
      @attrs.map { |a| a.name } 
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
