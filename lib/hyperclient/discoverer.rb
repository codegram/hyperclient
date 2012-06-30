module Hyperclient
  # Public: Discovers resources from a Representation.
  class Discoverer
    # Include goodness of Enumerable.
    include Enumerable

    # Public: Initializes a Discoverer.
    #
    # representation - A Hash representing some resources.
    def initialize(representation)
      @representation = representation
    end

    # Public: Fetch a Resource with the given name. It is useful when
    # resources don't have a friendly name and you can't call a method on the
    # Discoverer.
    #
    # name - A String representing the resource name.
    #
    # Returns a Resource
    def [](name)
      resources[name.to_s]
    end

    # Public: Iterates over the discovered resources so one can navigate easily
    # between them.
    #
    # block - A block to pass to each.
    # 
    # Returns an Enumerable.
    def each(&block)
      resources.values.each(&block)
    end

    # Public: Returns a Resource with the name of the method when exists.
    def method_missing(method, *args, &block)
      resources.fetch(method.to_s) { super }
    end

    private
    # Internal: Returns a Hash with the resources of the representation.
    def resources
      return {} unless @representation.respond_to?(:inject)

      @resources ||= @representation.inject({}) do |memo, (name, representation)|
        next memo if name == 'self'
        memo.update(name => build_resource(representation, name))
      end
    end

    # Internal: Returns a Resource (or a collection of Resources).
    #
    # representation - A Hash representing the resource representation.
    # name     - An optional String with the name of the resource.
    def build_resource(representation, name = nil)
      return representation.map(&method(:build_resource)) if representation.is_a?(Array)

      url = extract_url(representation)
      ResourceFactory.resource(url, {representation: representation, name: name})
    end

    # Internal: Returns a String with the resource URL
    #
    # representation - The JSON representation of the resource.
    def extract_url(representation)
      return representation['href'] if representation.include?('href')

      if representation && representation['_links'] && representation['_links']['self'] &&
          (url = representation['_links']['self']['href'])
        return url
      end
    end
  end
end

require 'hyperclient/resource_factory'
