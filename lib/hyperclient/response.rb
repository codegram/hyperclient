require 'hyperclient/discoverer'

module Hyperclient
  # Public: This class is responsible for parsing a response from the API
  # and exposing some methods to access its values.
  #
  # It is mainly used by Hyperclient::Resource.
  class Response
    # Public: Initializes a Response.
    #
    # response - A Hash representing the response from the API.
    def initialize(response)
      @response = response
    end

    # Public: Returns a Discoverer for the _links section of the response. It
    # can be used later to use the resources from this section.
    def links
      @links ||= Discoverer.new(@response['_links'])
    end

    # Public: Returns a Discoverer for the _embedded section of the response.
    # It can be used later to use the resources from this section.
    def resources
      @embedded ||= Discoverer.new(@response['_embedded'])
    end

    # Public: Returns a Hash with the attributes of the resource.
    def attributes
      @attributes ||= @response.dup.delete_if {|key, value| key =~ /^_/}
    end

    # Public: Returns a String with the resource URL or nil of it does not have
    # one.
    def url
      if @response && @response['_links'] && @response['_links']['self'] &&
          (url = @response['_links']['self']['href'])
        return url
      end
    end
  end
end
