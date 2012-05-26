require 'hyperclient/response'
require 'hyperclient/http'

module Hyperclient
  # Public: Represents a resource from your API. Its responsability is to
  # perform HTTP requests against itself and ease the way you access the
  # resource's data, links and embedded resources.
  class Resource
    extend Forwardable
    # Public: Delegate data and resources to the response.
    def_delegators :response, :data, :resources

    # Public: Delegate all HTTP methods (get, post, put, delete, options and
    # head) to @http.
    def_delegators :@http, :get, :post, :put, :delete, :options, :head

    # Internal: Initializes a Resource.
    #
    # url - A string with the url of the resource. Can be either absolute or
    # relative.
    #
    # response - An optional Hash representation of the resource's HTTP 
    # response.
    def initialize(url, response = nil)
      @url = url
      @http = HTTP.new(self)
      @response = Response.new(response) if response
    end

    # Internal: Sets the entry point for all the resources in your API client.
    #
    # url - A String with the URL of your API entry point.
    #
    # Returns nothing.
    def self.entry_point=(url)
      @@entry_point = URI(url)
    end

    # Internal: Returns the resource's absolute url.
    #
    # Returns nothing.
    def url
      @@entry_point.merge(@url).to_s
    end

    # Public: Gets a fresh response from the resource representation.
    #
    # Returns nothing.
    def reload
      @response = Response.new(get)
    end

    private

    # Private: Returns the resource response.
    def response
      reload unless @response
      @response
    end

    # Private: It defines an accessor for an existing resource inside the
    # current resource.
    #
    # Examples
    #
    #   post = Resource.new('/posts/1')
    #   post.author # Triggers method_missing defining a new author method.
    #
    # Returns nothing.
    def method_missing(method, *args, &block)
      if resources.include?(method.to_s)
        define_resource_accessor(method)
        send method, *args, &block
      else
        super
      end
    end

    # Private: Defines a method that fetches a resoruce with the same name.
    #
    # name - A String or Symbol of the method (resource) name.
    #
    # Returns nothing.
    def define_resource_accessor(name)
      self.class.class_eval do
        define_method "#{name}" do
          resources.fetch("#{name}")
        end
      end
    end
  end
end
