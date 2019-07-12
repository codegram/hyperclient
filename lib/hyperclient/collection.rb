# typed: strict
module Hyperclient
  # Public: A helper class to wrap a collection of elements and provide
  # Hash-like access or via a method call.
  #
  # Examples
  #
  #  collection['value']
  #  collection.value
  #
  class Collection
    extend T::Sig
    extend T::Generic
    Elem = type_member

    include Enumerable

    # Public: Initializes the Collection.
    #
    # collection - The Hash to be wrapped.
    sig {params(collection: Hash).void}
    def initialize(collection)
      @collection = T.let(collection, Hash)
    end

    # Public: Each implementation to allow the class to use the Enumerable
    # benefits.
    #
    # Returns an Enumerator.
    sig {implementation.returns(T::Hash[T.untyped, T.untyped])}
    def each(&block)
      @collection.each(&block)
    end

    # Public: Checks if this collection includes a given key.
    #
    # key - A String or Symbol to check for existance.
    #
    # Returns True/False.
    sig {params(key: T.any(String,Symbol)).returns(T::Boolean)}
    def include?(key)
      @collection.include?(key)
    end

    # Public: Returns a value from the collection for the given key.
    # If the key can't be found, there are several options:
    # With no other arguments, it will raise an KeyError exception;
    # if default is given, then that will be returned;
    #
    # key - A String or Symbol of the value to get from the collection.
    # default - An optional value to be returned if the key is not found.
    #
    # Returns an Object.
    sig { params(args: T.untyped).returns(T.untyped)}
    def fetch(*args)
      T.unsafe(@collection).fetch(*args)
    end

    # Public: Provides Hash-like access to the collection.
    #
    # name - A String or Symbol of the value to get from the collection.
    #
    # Returns an Object.
    sig {params(name: T.any(String,Symbol)).returns(T.untyped)}
    def [](name)
      @collection[name.to_s]
    end

    # Public: Returns the wrapped collection as a Hash.
    #
    # Returns a Hash.
    sig {returns(T::Hash[T.untyped, T.untyped])}
    def to_h
      @collection.to_hash
    end
    alias to_hash to_h

    sig {returns(Hash)}
    def to_s
      to_hash
    end

    # Public: Provides method access to the collection values.
    #
    # It allows accessing a value as `collection.name` instead of
    # `collection['name']`
    #
    # Returns an Object.
    sig do
      params(
        method_name: T.any(String, Symbol),
        _args: T.untyped
      ).returns(T.untyped)
    end
    def method_missing(method_name, *_args, &_block)
      @collection.fetch(method_name.to_s) do
        raise "Could not find `#{method_name}` in #{self.class.name}"
      end
    end

    # Internal: Accessory method to allow the collection respond to the
    # methods that will hit method_missing.
    sig {params(method_name: T.untyped, _include_private: T::Boolean).returns(T::Boolean)}
    def respond_to_missing?(method_name, _include_private = false)
      @collection.include?(method_name.to_s)
    end
  end
end
