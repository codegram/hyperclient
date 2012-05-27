require 'hyperclient/discoverer'

module Hyperclient
  # Internal: This class is responsible for parsing a response from the API
  # and exposing some methods to access its values.
  #
  # It is mainly used by Hyperclient::Resource.
  class Response
    extend Forwardable

    # Public: Initializes a Response.
    #
    # response - A Hash representing the response from the API.
    def initialize(response)
      @response = response
      @discoverer = Discoverer.new(@response)
    end

    # Public: Returns a collection of resources, including the ones discovered
    # at the _links section and the _embedded section.
    def resources
      unless defined?(@resources)
        @resources = @discoverer.links.merge(@discoverer.embedded)
      end

      @resources
    end

    # Public: Returns a Hash with the attributes of the resource.
    def attributes
      @attributes ||= @response.delete_if {|key, value| key =~ /^_/}
    end

    # Public: Returns a String with the resource URL.
    def url
      @response['_links']['self']['href']
    end

    # Public: Returns a True or False wether the response includes a URL to the
    # resource or not. Determines if the Resoruce should update its URL.
    def has_url?
      !!(@response && @response['_links'] && @response['_links']['self'] &&
        @response['_links']['self']['href'])
    end
  end
end
