module Hyperclient
  class ResourceCollection
    def initialize(representation)
      @resources = representation['_embedded']
    end
  end
end
