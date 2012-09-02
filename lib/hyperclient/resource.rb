require 'hyperclient/attributes'
require 'hyperclient/link_collection'
require 'hyperclient/resource_collection'

module Hyperclient
  # Public: Represents a resource from your API. Its responsability is to
  # perform HTTP requests against itself and ease the way you access the
  # resource's attributes, links and embedded resources.
  class Resource
    extend Forwardable
    attr_accessor :attributes, :links, :embedded

    # Public: Delegate all HTTP methods (get, post, put, delete, options and
    # head) to Hyperclient::HTTP.
    def_delegators :self_link, :get, :post, :put, :delete, :options, :head

    def initialize(representation)
      @links      = LinkCollection.new(representation['_links'])
      @embedded   = ResourceCollection.new(representation['_embedded'])
      @attributes = Attributes.new(representation)
    end

    private
    def self_link
      @links['self']
    end
  end
end
