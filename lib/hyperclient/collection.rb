module Hyperclient
  # Public: A helper class to wrapp a collection of elements and provide
  # Hash-like access or via a method call.
  #
  # Examples
  #
  #  collection['value']
  #  collection.value
  #
  class Collection < Hash

    # Public: Initializes the Collection.
    #
    # collection - The Hash to be wrapped.
    def initialize(collection)
      update collection
    end

    # Public: Provides Hash-like access to the collection.
    #
    # name - A String or Symbol of the value to get from the collection.
    #
    # Returns an Object.
    def [](name)
      super name.to_s
    end

    # Public: Provides method access to the collection values.
    #
    # It allows accessing a value as `collection.name` instead of
    # `collection['name']`
    #
    # Returns an Object.
    def method_missing(method_name, *args, &block)
      fetch(method_name.to_s)  do
        raise "Could not find `#{method_name.to_s}` in #{self.class.name}"
      end
    end

    # Internal: Accessory method to allow the collection respond to the
    # methods that will hit method_missing.
    def respond_to_missing?(method_name, include_private = false)
      include?(method_name.to_s)
    end
  end
end
