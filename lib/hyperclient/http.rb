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
    def initialize(resource)
      @resource = resource
    end

    # Public: Sends a GET request the the resource url.
    #
    # Returns: The response parsed response.
    def get
      self.class.get(url).parsed_response
    end

    # Public: Sends a POST request the the resource url.
    #
    # params - A Hash to send as POST params
    #
    # Returns: A HTTParty::Response
    def post(params)
      self.class.post(url, params)
    end

    # Public: Sends a PUT request the the resource url.
    #
    # params - A Hash to send as PUT params
    #
    # Returns: A HTTParty::Response
    def put(params)
      self.class.put(url, params)
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
  end
end
