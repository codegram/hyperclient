require 'httparty'
require 'forwardable'

# Public: A parser for HTTParty that understand the mime application/hal+json.
class JSONHalParser < HTTParty::Parser
  SupportedFormats.merge!({'application/hal+json' => :json})
end

module Hyperclient
  # Internal: This class wrapps HTTParty and performs the HTTP requests for a
  # resource.
  class HTTP
    extend Forwardable
    include HTTParty

    parser JSONHalParser

    # Private: Delegate the url to the resource.
    def_delegators :@resource, :url

    # Public: Initializes a HTTP agent.
    #
    # resource - A Resource instance. A Resource is given instead of the url
    # since the resource url could change during its live.
    def initialize(resource, options = {})
      @resource = resource
      authenticate(options[:auth]) if options && options.include?(:auth)
      headers(options[:headers]) if options && options.include?(:headers)
    end

    # Public: Sends a GET request the the resource url.
    #
    # Returns: The parsed response.
    def get
      self.class.get(url).parsed_response
    end

    # Public: Sends a POST request the the resource url.
    #
    # params - A Hash to send as POST params
    #
    # Returns: A HTTParty::Response
    def post(params)
      self.class.post(url, body: params)
    end

    # Public: Sends a PUT request the the resource url.
    #
    # params - A Hash to send as PUT params
    #
    # Returns: A HTTParty::Response
    def put(params)
      self.class.put(url, body: params)
    end

    # Public: Sends an OPTIONS request the the resource url.
    #
    # Returns: A HTTParty::Response
    def options
      self.class.options(url)
    end

    # Public: Sends a HEAD request the the resource url.
    #
    # Returns: A HTTParty::Response
    def head
      self.class.head(url)
    end

    # Public: Sends a DELETE request the the resource url.
    #
    # Returns: A HTTParty::Response
    def delete
      self.class.delete(url)
    end

    private
    # Internal: Sets the authentication method for HTTParty.
    #
    # options - An options Hash to set the authentication options.
    #           :type        - A String or Symbol to set the authentication type.
    #           Can be either :digest or :basic.
    #           :credentials - An Array of Strings with the user and password.
    #
    # Returns nothing.
    def authenticate(options)
      auth_method = options[:type].to_s + '_auth'
      self.class.send(auth_method, *options[:credentials])
    end

    # Internal: Adds default headers for all the requests.
    #
    # headers - A Hash with the header.
    #
    # Example:
    #   headers({'accept-encoding' => 'deflate, gzip'})
    #
    # Returns nothing.
    def headers(headers)
      self.class.send(:headers, headers)
    end
  end
end
