require 'hyperclient/collection'
require 'hyperclient/link'

module Hyperclient
  class LinkCollection < Collection
    def initialize(collection, entry_point)
      @collection = (collection || {}).inject({}) do |hash, (name, link)|
        hash.update(name => Link.new(link, entry_point))
      end
    end
  end
end
