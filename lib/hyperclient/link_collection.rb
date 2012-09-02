require 'hyperclient/collection'
require 'hyperclient/link'

module Hyperclient
  class LinkCollection < Collection
    def initialize(collection)
      @collection = (collection || {}).inject({}) do |hash, (name, link)|
        hash.update(name => Link.new(link))
      end
    end
  end
end
