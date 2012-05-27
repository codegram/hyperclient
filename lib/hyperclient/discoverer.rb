module Hyperclient
  # Internal: Discovers resources from an HTTP response.
  class Discoverer
    # Public: Initializes a Discoverer.
    #
    # response - A Hash representing an HTTP response of a resource.
    def initialize(response)
      @response = response
    end

    # Public: Returns a collection of Hyperclient::Resource extracted from the
    # _links response.
    def links
      discover_resources_from(@response['_links'])
    end

    # Public: Returns a collection of Hyperclient::Resource extracted from the
    # _embedded response.
    def embedded
      discover_resources_from(@response['_embedded'])
    end

    private

    # Private: Returns a Hash with the names of the resources as keys and the
    # resources as values.
    def discover_resources_from(resources)
      return {} unless resources.respond_to?(:inject)

      resources.inject({}) do |resources, (name, resource)|
        next resources if name == 'self'
        resources.update(name => build_resource(resource))
      end
    end

    # Private: Returns a Resource (or a collection of Resources).
    def build_resource(resource)
      return resource.map(&method(:build_resource)) if resource.is_a?(Array)

      Resource.new(resource.delete('href'), resource)
    end
  end
end

require 'hyperclient/resource'
