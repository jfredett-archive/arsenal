module Arsenal
  class Attribute
    attr_reader :name, :default

    def value(instance)
      return @default unless instance.respond_to?(method) 
      instance.send(method)  
    end

    def has_default?
      @default.present?
    end

    def required? 
      !!@required
    end

    def initialize(name, opts = {})
      @name = name
      @method = opts[:method]
      @default = opts[:default]
      @required = opts[:required]
    end

    def to_s
      first_part = "#{name} => #{method}" 
      second_part = "(default: #{default})" if has_default?
      [first_part, second_part].join(' ') 
    end
    alias inspect to_s

    private 

    def method 
      method = @method || @name
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
    alias push <<

    def [](key)
      @attrs.each do |a|
        return a if a.name == key
      end
      nil
    end

    def to_hash(obj)
      @attrs.each.with_object({}) do |e,a|
        a[e.name] = e.value(obj)
      end
    end

    def each(&block)
      @attrs.each(&block)
    end
    def ==(other)
      attrs = @attrs.dup
      other.each do |attr|
        return false unless attrs.include?(attr)
        attrs.delete(attr)
      end
      attrs.empty? 
    end
  end
end
