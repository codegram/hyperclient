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
      # @links ||= Discoverer.new(@representation['_links'])
      @links ||= LinkCollection.new(@representation['_links'])
    end

    # Public: Returns a Discoverer for the _embedded section of the representation.
    # It can be used later to use the resources from this section.
    def embedded
      @embedded ||= Discoverer.new(@representation['_embedded'])
    end

    # Public: Returns a Hash with the attributes of the resource.
    def attributes
      @attributes ||= @representation.dup.delete_if {|key, value| key =~ /^_/}
    end
  end

  class LinkCollection
    include Enumerable

    def initialize(links)
      @raw_links = links
    end

    def each(&block)
      links.values.each(&block)
    end

    def [](name)
      links[name.to_s]
    end

    def method_missing(method_name, *args, &block)
      links.fetch(method_name.to_s) { super }
    end

    def respond_to_missing?(method_name, include_private = false)
      links.include?(method_name.to_s)
    end

    def links
      @links ||= @raw_links.reduce({}) do |hash, (relation, link)|
        hash.update(relation => Link.new(relation, link.delete('href'), link))
      end
    end
  end

  class Link
    def initialize(relation, href, options)
      @relation, @href, @options = relation, href, options
    end

    def templated?
      @options['templated'] && @options['templated'] == true
    end

    def resource(uri_variables = nil)
      ResourceFactory.resource(url(uri_variables), {name: @relation})
    end

    def url(uri_variables = nil)
      return href unless templated?
      raise MissingURITemplateVariablesException.new(options.keys) unless uri_variables

      @url ||= URITemplate.new(@href).expand_uri(uri_variables)
    end
  end

  # Public: Exception that is raised when building a Resource without a URL.
  class MissingURITemplateVariablesException < StandardError
    # Public: Initializes a MissingURLException
    #
    # args - An Array of the args the were to be used to build the Resource.
    def initialize(variables)
      @variables = variables
    end

    # Public: Returns a String with the exception message.
    def message
      "The URL to this resource is templated, but no variables where given. The variables for the template are: #{@variables.join(', ').inspect}"
    end
  end
end

require 'json'
