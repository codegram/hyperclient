module Hyperclient
  # Public: Discovers resources from an HTTP response.
  class Discoverer
    # Public: Initializes a Discoverer.
    #
    # response - A Hash representing some resources.
    def initialize(response)
      @response = response
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
    # Internal: Returns a Hash with the resources of the response.
    def resources
      return {} unless @response.respond_to?(:inject)

      @resources ||= @response.inject({}) do |memo, (name, response)|
        next memo if name == 'self'
        memo.update(name => build_resource(response, name))
      end
    end

    # Internal: Returns a Resource (or a collection of Resources).
    #
    # response - A Hash representing the resource response.
    # name     - An optional String with the name of the resource.
    def build_resource(response, name = nil)
      return response.map(&method(:build_resource)) if response.is_a?(Array)

      Resource.new(response.delete('href'), {response: response, name: name})
    end
  end
end

require 'hyperclient/resource'
