require 'forwardable'
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

    # Public: Returns the response object for the HTTP request that created this
    # resource, if one exists.
    attr_reader :response

    # Public: Delegate all HTTP methods (get, post, put, delete, options and
    # head) to its self link.
    def_delegators :self_link, :get, :post, :put, :delete, :options, :head

    # Public: Initializes a Resource.
    #
    # representation - The hash with the HAL representation of the Resource.
    # entry_point    - The EntryPoint object to inject the configutation.
    def initialize(representation, entry_point, response=nil)
      representation ||= {}
      @links       = LinkCollection.new(representation['_links'], entry_point)
      @embedded    = ResourceCollection.new(representation['_embedded'], entry_point)
      @attributes  = Attributes.new(representation)
      @entry_point = entry_point
      @response    = response
    end

    def inspect
      "#<#{self.class.name} self_link:#{self_link.inspect} attributes:#{@attributes.inspect}>"
    end

    def success?
      response && response.success?
    end

    def status
      response && response.status
    end

    private
    # Internal: Returns the self Link of the Resource. Used to handle the HTTP
    # methods.
    def self_link
      @links['self']
    end
  end
end
