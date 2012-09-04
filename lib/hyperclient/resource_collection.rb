require 'hyperclient/collection'
require 'hyperclient/resource'

module Hyperclient
  class ResourceCollection < Collection
    def initialize(collection = {})
      @collection = (collection || {}).inject({}) do |hash, (name, resource)|
        hash.update(name => build_resource(resource))
      end
    end

    private
    def build_resource(representation)
      return representation.map(&method(:build_resource)) if representation.is_a?(Array)

      Resource.new(representation)
    end
  end
end