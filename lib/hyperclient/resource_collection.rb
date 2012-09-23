require 'hyperclient/collection'
require 'hyperclient/resource'

module Hyperclient
  # Public: A wrapper class to easily acces the embedded resources in a
  # Resource.
  #
  # Examples
  #
  #   resource.embedded['comments']
  #   resource.embedded.comments
  #
  class ResourceCollection < Collection
    # Public: Initializes a ResourceCollection.
    #
    # collection  - The Hash with the embedded resources.
    # entry_point - The EntryPoint object to inject the cofnigutation.
    #
    def initialize(collection, entry_point)
      @entry_point = entry_point
      @collection = (collection || {}).inject({}) do |hash, (name, resource)|
        hash.update(name => build_resource(resource))
      end
    end

    private
    def build_resource(representation)
      return representation.map(&method(:build_resource)) if representation.is_a?(Array)

      Resource.new(representation, @entry_point)
    end
  end
end
