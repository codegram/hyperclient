require 'hyperclient/http'
require 'hyperclient/resource'
require 'uri_template'

module Hyperclient
  #
  # api.links.posts.resource(q: 'hola')
  #
  # api.links.posts.templated?
  #
  # api.links.posts.templated(uri_variables).post(params)
  class Link
    extend Forwardable
    # Public: Delegate all HTTP methods (get, post, put, delete, options and
    # head) to Hyperclient::HTTP.
    def_delegators :http, :get, :post, :put, :delete, :options, :head

    def initialize(link, entry_point, uri_variables = nil)
      @link          = link
      @entry_point   = entry_point
      @uri_variables = uri_variables
    end

    def resource
      Resource.new http.get, @entry_point
    end

    def templated?
      !!@link['templated']
    end

    def templated(uri_variables)
      self.class.new(@link, @entry_point, uri_variables)
    end

    def url
      return @link['href'] unless templated?
      raise MissingURITemplateVariablesException if @uri_variables == nil

      @url ||= URITemplate.new(@link['href']).expand(@uri_variables)
    end

    private
    def http
      @http ||= HTTP.new url, @entry_point.config
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

    def respond_to_missing?(method, include_private = false)
      resource.respond_to?(method.to_s)
    end
  end

  # Public: Exception that is raised when building a Resource without a URL.
  class MissingURITemplateVariablesException < StandardError

    # Public: Returns a String with the exception message.
    def message
      "The URL to this links is templated, but no variables where given."
    end
  end
end
