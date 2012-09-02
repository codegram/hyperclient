require 'hyperclient/http'
require 'hyperclient/resource'
require 'uri_template'

module Hyperclient
  class Link
    extend Forwardable

    attr_reader :href, :templated, :type, :name, :profile, :title, :hreflang
    attr_accessor :uri_variables

    # Public: Delegate all HTTP methods (get, post, put, delete, options and
    # head) to Hyperclient::HTTP.
    def_delegators :http, :get, :post, :put, :delete, :options, :head

    def initialize(link)
      @href      = link['href']
      @templated = link['templated']
      @type      = link['type']
      @name      = link['name']
      @profile   = link['profile']
      @title     = link['title']
      @hreflang  = link['hreflang']
    end

    def resource(uri_variables = nil)
      @uri_variables = uri_variables

      Resource.new http.get
    end

    def templated?
      !!@templated
    end

    private
    def http
      @http ||= HTTP.new url
    end

    def url
      return @href unless templated?
      raise MissingURITemplateVariablesException unless @uri_variables

      @url ||= URITemplate.new(@href).expand(@uri_variables)
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
