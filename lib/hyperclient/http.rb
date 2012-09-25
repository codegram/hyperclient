require 'faraday'
require 'json'

module Hyperclient
  # Internal: This class wrapps HTTParty and performs the HTTP requests for a
  # resource.
  class HTTP
    class ResponseWrapper
      attr_reader :faraday_response

      def initialize(faraday_response)
        @faraday_response = faraday_response
      end

      def code
        faraday_response.status
      end

      def body
        faraday_response.body
      end

      def headers
        faraday_response.headers
      end
    end
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
      JSON.parse(faraday.get(url).body)
    end

    # Public: Sends a POST request the the resource url.
    #
    # params - A Hash to send as POST params
    #
    # Returns: A HTTParty::Response
    def post(params)
      wrap_response faraday.post(url, params)
    end

    # Public: Sends a PUT request the the resource url.
    #
    # params - A Hash to send as PUT params
    #
    # Returns: A HTTParty::Response
    def put(params)
      wrap_response faraday.put(url, params)
    end

    # Public: Sends an OPTIONS request the the resource url.
    #
    # Returns: A HTTParty::Response
    def options
      wrap_response faraday.run_request(:options, url, nil, faraday.headers)
    end

    # Public: Sends a HEAD request the the resource url.
    #
    # Returns: A HTTParty::Response
    def head
      wrap_response faraday.head(url)
    end

    # Public: Sends a DELETE request the the resource url.
    #
    # Returns: A HTTParty::Response
    def delete
      wrap_response faraday.delete(url)
    end

    private

    def faraday
      @faraday ||= Faraday.new(:url => @url, :headers => @config[:headers] || {}) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter :net_http
      end
    end

    def wrap_response(faraday_response)
      ResponseWrapper.new faraday_response
    end

    # Internal: Sets the authentication method for HTTParty.
    #
    # options - An options Hash to set the authentication options.
    #
    # Returns nothing.
    def authenticate!
      if (options = @config[:auth])
        auth_method = options.fetch(:type).to_s + '_auth'
        faraday.send(auth_method, options[:user], options[:password])
      end
    end

    # Internal: Enables HTTP debugging.
    #
    # stream - An object to stream the HTTP out to or just a truthy value.
    def toggle_debug!
      stream = @config[:debug]
      require 'logger'

      if stream.respond_to?(:<<)
        faraday.response :logger, ::Logger.new(stream)
      else
        faraday.response :logger, ::Logger.new($stderr)
      end
    end
  end
end
