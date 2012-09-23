require 'hyperclient/http'
require 'hyperclient/resource'
require 'uri_template'

module Hyperclient
  # Internal: The Link is  used to let a Resource interact with the API.
  #
  class Link
    extend Forwardable
    # Public: Delegate all HTTP methods (get, post, put, delete, options and
    # head) to the http connection.
    def_delegators :http, :get, :post, :put, :delete, :options, :head

    # Public: Initializes a new Link.
    #
    # link          - The String with the URI of the link.
    # entry_point   - The EntryPoint object to inject the cofnigutation.
    # uri_variables - The optional Hash with the variables to expand the link
    #                 if it is templated.
    def initialize(link, entry_point, uri_variables = nil)
      @link          = link
      @entry_point   = entry_point
      @uri_variables = uri_variables
    end

    # Public: Returns the Resource which the Link is pointing to.
    def resource
      @resource ||=Resource.new(http.get, @entry_point)
    end

    # Public: Indicates if the link is an URITemplate or a regular URI.
    #
    # Returns true if it is templated.
    # Returns false if it nos templated.
    def templated?
      !!@link['templated']
    end

    # Public: Expands the Link when is templated with the given variables.
    #
    # uri_variables - The Hash with the variables to expand the URITemplate.
    #
    # Returns a new Link with the expanded variables.
    def expand(uri_variables)
      self.class.new(@link, @entry_point, uri_variables)
    end

    # Public: Returns the url of the Link.
    #
    # Raises MissingURITemplateVariables if the Link is templated but there are
    # no uri variables to expand it.
    def url
      return @link['href'] unless templated?
      raise MissingURITemplateVariablesException if @uri_variables == nil

      @url ||= URITemplate.new(@link['href']).expand(@uri_variables)
    end

    private
    # Internal: Returns the HTTP client used to interact with the API.
    def http
      @http ||= HTTP.new(url, @entry_point.config)
    end

    # Internal: Delegate the method to the API if it exists.
    #
    # This allows `api.links.posts.embedded` instead of
    # `api.links.posts.resource.embedded`
    def method_missing(method, *args, &block)
      if resource.respond_to?(method)
        resource.send(method, *args, &block)
      else
        super
      end
    end

    # Internal: Accessory method to allow the link respond to the
    # methods that will hit method_missing.
    def respond_to_missing?(method, include_private = false)
      resource.respond_to?(method.to_s)
    end
  end

  # Public: Exception that is raised when building a templated Link without uri
  # variables.
  class MissingURITemplateVariablesException < StandardError

    # Public: Returns a String with the exception message.
    def message
      "The URL to this links is templated, but no variables where given."
    end
  end
end
