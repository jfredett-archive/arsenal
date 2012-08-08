module Arsenal
  class Registry
    extend Forwardable
    include Enumerable

    delegate [:[], :has_key?, :each] => :registry

    def initialize(registry = {}, &block)
      @mapper = block
      @original_registry = registry
      clear!(registry)
    end

    def register(registrant)
      registry[registrant] = mapper.call(registrant)
    end
    alias register! register

    def clear!(registry = nil)
      @registry = registry || @original_registry
      self
    end

    private

    attr_reader :registry, :mapper
  end
end
