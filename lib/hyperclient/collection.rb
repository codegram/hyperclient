module Hyperclient
  class Collection
    include Enumerable

    def initialize(collection)
      @collection = collection
    end

    def each(&block)
      @collection.each(&block)
    end

    def [](name)
      @collection[name.to_s]
    end

    def method_missing(method_name, *args, &block)
      @collection.fetch(method_name.to_s) { super }
    end

    def respond_to_missing?(method_name, include_private = false)
      @collection.include?(method_name.to_s)
    end
  end
end
