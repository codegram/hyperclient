require 'hyperclient/discoverer'

module Hyperclient
  # Public: This class is responsible for parsing a representation from the API
  # and exposing some methods to access its values.
  #
  # It is mainly used by Hyperclient::Resource.
  class Representation
    # Public: Initializes a Representation.
    #
    # representation - A Hash containing a representation from the API. If the
    # representation is not a Hash it will try to parse it as JSON.
    def initialize(representation)
      begin
        representation = JSON.parse(representation) unless representation.is_a? Hash
      rescue JSON::ParserError
        warn 'WARNING Hyperclient::Representation: JSON representation was not valid:'
        puts representation
        representation = {}
      end
      @representation = representation
    end

    # Public: Returns a Discoverer for the _links section of the representation. It
    # can be used later to use the resources from this section.
    def links
      @links ||= Discoverer.new(@representation['_links'])
    end

    # Public: Returns a Discoverer for the _embedded section of the representation.
    # It can be used later to use the resources from this section.
    def resources
      @embedded ||= Discoverer.new(@representation['_embedded'])
    end

    # Public: Returns a Hash with the attributes of the resource.
    def attributes
      @attributes ||= @representation.dup.delete_if {|key, value| key =~ /^_/}
    end

    # Public: Returns a String with the resource URL or nil of it does not have
    # one.
    def url
      if @representation && @representation['_links'] && @representation['_links']['self'] &&
          (url = @representation['_links']['self']['href'])
        return url
      end
    end
  end
end

require 'json'
