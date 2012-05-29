require 'hyperclient/response'
require 'hyperclient/http'

module Hyperclient
  # Public: Represents a resource from your API. Its responsability is to
  # perform HTTP requests against itself and ease the way you access the
  # resource's attributes, links and embedded resources.
  class Resource
    extend Forwardable
    # Public: Delegate attributes and resources to the response.
    def_delegators :response, :attributes, :resources, :links

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
    #           :response - An optional Hash representation of the resource's 
    #           HTTP response.
    #           :http     - An optional Hash to pass to the HTTP class.
    def initialize(url, options = {})
      @url = url
      @name = options[:name]
      @http = HTTP.new(self, options[:http])
      initialize_response(options[:response])
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

    # Public: Gets a fresh response from the resource representation.
    #
    # Returns itself (this way you can chain method calls).
    def reload
      initialize_response(get)
      self
    end

    private
    # Internal: Initializes a Response
    #
    # raw_response - A Hash representing the HTTP response for the resource.
    #
    # Return nothing.
    def initialize_response(raw_response)
      if raw_response && raw_response.is_a?(Hash) && !raw_response.empty?
        @response = Response.new(raw_response)
        @url = @response.url if @response.url
      end
    end

    # Internal: Returns the resource response.
    def response
      reload unless @response
      @response
    end
  end
end
