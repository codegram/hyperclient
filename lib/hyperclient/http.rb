require 'httparty'
require 'json'

# Public: A parser for HTTParty that understand the mime application/hal+json.
class JSONHalParser < HTTParty::Parser
  SupportedFormats.merge!({'application/hal+json' => :json})
end

module Hyperclient
  # Internal: This class wrapps HTTParty and performs the HTTP requests for a
  # resource.
  class HTTP
    include HTTParty
    parser JSONHalParser

    # Public: Initializes the HTTP agent.
    #
    # url    - A String to send the HTTP requests.
    # config - A Hash with the configuration of the HTTP connection.
    #          :headers - The Hash with the headers of the connection.
    #          :auth    - The Hash with the authentication options:
    #            :type     - A String or Symbol to set the authentication type.
    #                        Allowed values are :digest or :basic.
    #            :user     - A String with the user.
    #            :password - A String with the user.
    #          :debug   - The flag (true/false) to debug the HTTP connections.
    #
    def initialize(url, config)
      @url      = url
      @config   = config
      @base_uri = config.fetch(:base_uri)

      authenticate!
      toggle_debug! if @config[:debug]

      self.class.headers(@config[:headers]) if @config.include?(:headers)
    end

    def url
      begin
        URI.parse(@base_uri).merge(@url).to_s
      rescue URI::InvalidURIError
        @url
      end
    end

    # Public: Sends a GET request the the resource url.
    #
    # Returns: The parsed response.
    def get
      JSON.parse(self.class.get(url).response.body)
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
    #
    # Returns nothing.
    def authenticate!
      if (options = @config[:auth])
        auth_method = options.fetch(:type).to_s + '_auth'
        self.class.send(auth_method, options[:user], options[:password])
      end
    end

    # Internal: Enables HTTP debugging.
    #
    # stream - An object to stream the HTTP out to or just a truthy value. 
    def toggle_debug!
      stream = @config[:debug]

      if stream.respond_to?(:<<)
        self.class.debug_output(stream)
      else
        self.class.debug_output
      end
    end
  end
end
