require 'hyperclient/collection'
require 'hyperclient/link'

module Hyperclient
  # Public: A wrapper class to easily acces the links in a  Resource.
  #
  # Examples
  #
  #   resource.links['author']
  #   resource.links.author
  #
  class LinkCollection < Collection
    # Public: Initializes a LinkCollection.
    #
    # collection  - The Hash with the links.
    # entry_point - The EntryPoint object to inject the cofnigutation.
    #
    def initialize(collection, entry_point)
      raise "Invalid response for LinkCollection. The response was: #{collection.inspect}" if collection && !collection.respond_to?(:inject)
      @collection = (collection || {}).inject({}) do |hash, (name, link)|
        hash.update(name => Link.new(link, entry_point))
      end
    end
  end
end
