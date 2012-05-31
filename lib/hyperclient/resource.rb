require 'hyperclient/representation'
require 'hyperclient/http'

module Hyperclient
  # Public: Represents a resource from your API. Its responsability is to
  # perform HTTP requests against itself and ease the way you access the
  # resource's attributes, links and embedded resources.
  class Resource
    extend Forwardable
    # Public: Delegate attributes and resources to the representation.
    def_delegators :representation, :attributes, :resources, :links

    # Public: Delegate all HTTP methods (get, post, put, delete, options and
    # head) to Hyperclient::HTTP.
    def_delegators :@http, :get, :post, :put, :delete, :options, :head

    # Public: A String representing the Resource name.
    attr_reader :name

    # Public: Initializes a Resource.
    #
    # url - A String with the url of the resource. Can be either absolute or
    # relative.
    #
    # options - An options Hash to initialize different values:
    #           :name     - The String name of the resource.
    #           :representation - An optional Hash representation of the resource's 
    #           HTTP representation.
    #           :http     - An optional Hash to pass to the HTTP class.
    def initialize(url, options = {})
      @url = url
      @name = options[:name]
      @http = HTTP.new(self, options[:http])
      initialize_representation(options[:representation])
    end

    # Public: Sets the entry point for all the resources in your API client.
    #
    # url - A String with the URL of your API entry point.
    #
    # Returns nothing.
    def self.entry_point=(url)
      @@entry_point = URI(url)
    end

    # Public: Returns A String representing the resource url.
    def url
      begin
        @@entry_point.merge(@url).to_s
      rescue URI::InvalidURIError
        @url
      end
    end

    # Public: Gets a fresh representation from the resource representation.
    #
    # Returns itself (this way you can chain method calls).
    def reload
      initialize_representation(get)
      self
    end

    private
    # Internal: Initializes a Representation
    #
    # raw_representation - A Hash representing the HTTP representation for the resource.
    #
    # Return nothing.
    def initialize_representation(raw_representation)
      if raw_representation && raw_representation.is_a?(Hash) && !raw_representation.empty?
        @representation = Representation.new(raw_representation)
        @url = @representation.url if @representation.url
      end
    end

    # Internal: Returns the resource representation.
    def representation
      reload unless @representation
      @representation
    end
  end
end
