module Arsenal
  # A single attribute on a model
  #
  # @see Arsenal::Model
  class Attribute
    attr_reader :name, :default

    # Given a model instance, determine the value of this attribute
    #
    # @param instance [Arsenal::Model] the instance to evaluate against
    #
    # @return [Object,nil] the value of this attribute
    def value(instance)
      return @default unless instance.respond_to?(method) 
      instance.send(method)  
    end

    # Whether or not the attribute has a default value.
    #
    # @return [Boolean] true if the attribute has a default, false otherwise.
    def has_default?
      @default.present?
    end

    # Whether or not the attribute is required in the context of a given
    # instance. If no instance is given, `nil` will be pass to any proc that's
    # been provided.
    #
    # @param value [Arsenal::Model] the instance to evaluate against
    #
    # @return [Boolean] true if the attribute is required, false otherwise.
    def required?(value = nil)
      return !!@required.call(value) if @required.respond_to?(:call)
      return !!@required
    end

    # Create a new attribute see {Arsenal::Macros#attribute? Arsenal::Macros#attribute?}
    # for details on the available options
    #
    # @todo: relocate option docs to here.
    #
    # @param name [Symbol] the name of the method which should be populated by 
    #  the attribute.
    # @param opts [Hash] the set of options, described above, for the hash
    #
    # @return [Attribute] a new attribute with the given options.
    def initialize(name, opts = {})
      @name = name
      @method = opts[:method]
      @default = opts[:default]
      @required = opts[:required]
    end

    # @private
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
end
