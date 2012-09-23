require 'hyperclient/attributes'
require 'hyperclient/link_collection'
require 'hyperclient/resource_collection'

module Hyperclient
  # Public: Represents a resource from your API. Its responsability is to
  # ease the way you access its  attributes, links and embedded resources.
  class Resource
    extend Forwardable

    # Public: Returns the attributes of the Resource as Attributes.
    attr_reader :attributes

    # Public: Returns the links of the Resource as a LinkCollection.
    attr_reader :links

    # Public: Returns the embedded resource of the Resource as a
    # ResourceCollection.
    attr_reader :embedded

    # Public: Delegate all HTTP methods (get, post, put, delete, options and
    # head) to its Link.
    def_delegators :self_link, :get, :post, :put, :delete, :options, :head

    # Public: Initializes a Resource.
    # representation - The hash with the HAL representation of the Resource.
    # entry_point    - The EntryPoint object to inject the cofnigutation.
    def initialize(representation, entry_point)
      @links       = LinkCollection.new(representation['_links'], entry_point)
      @embedded    = ResourceCollection.new(representation['_embedded'], entry_point)
      @attributes  = Attributes.new(representation)
      @entry_point = entry_point
    end

    private
    # Internal: Returns the self Link of the Resource. Used to handle the HTTP
    # connections.
    def self_link
      @links['self']
    end
  end
end
