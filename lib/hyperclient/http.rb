require 'faraday'
require 'json'
require 'net/http/digest_auth'

module Hyperclient
  # Internal: This class wrapps HTTParty and performs the HTTP requests for a
  # resource.
  class HTTP
    attr_writer :faraday
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
    #          :faraday_options - A Hash that will be passed to Faraday.new (optional).
    #                             Can additionally include a :block => <Proc> that is also
    #                             passed to Faraday.
    #
    def initialize(url, config)
      @url      = url
      @config   = config
      @base_uri = config.fetch(:base_uri)
      @faraday_options = (config[:faraday_options] || {}).dup
      @faraday_block = @faraday_options.delete(:block)

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
      response = process_request :get

      if body = response.body
        JSON.parse(body)
      end
    end

    # Public: Sends a POST request the the resource url.
    #
    # params - A Hash to send as POST params
    #
    # Returns: A HTTParty::Response
    def post(params)
      wrap_response process_request(:post, params)
    end

    # Public: Sends a PUT request the the resource url.
    #
    # params - A Hash to send as PUT params
    #
    # Returns: A HTTParty::Response
    def put(params)
      wrap_response process_request(:put, params)
    end

    # Public: Sends an OPTIONS request the the resource url.
    #
    # Returns: A HTTParty::Response
    def options
      wrap_response process_request(:options)
    end

    # Public: Sends a HEAD request the the resource url.
    #
    # Returns: A HTTParty::Response
    def head
      wrap_response process_request(:head)
    end

    # Public: Sends a DELETE request the the resource url.
    #
    # Returns: A HTTParty::Response
    def delete
      wrap_response process_request(:delete)
    end

    private

    def faraday
      default_block = lambda do |faraday|
          faraday.request  :url_encoded
          faraday.adapter :net_http
      end
      @faraday ||= Faraday.new({:url => @base_uri, :headers => @config[:headers] || {}
        }.merge(@faraday_options), &(@faraday_block || default_block))
    end

    def wrap_response(faraday_response)
      def faraday_response.code
        status
      end
      faraday_response
    end

    def process_request(method, params = nil)
      response = faraday.run_request method, url, params, faraday.headers
      if response.status == 401 && @digest_auth
        response = faraday.run_request method, url, nil, faraday.headers do |request|
          request.headers['Authorization'] = digest_auth_header(
            url,  response.headers['www-authenticate'], method)
        end
      end
      response
    end

    # Internal: Sets the authentication method for HTTParty.
    #
    # options - An options Hash to set the authentication options.
    #
    # Returns nothing.
    def authenticate!
      if (options = @config[:auth])
        auth_method = options.fetch(:type).to_s + '_auth'
        send auth_method, options
      end
    end

    def basic_auth(options)
      faraday.basic_auth options[:user], options[:password]
    end

    def digest_auth(options)
      @digest_auth = options
    end

    def digest_auth_header(url, realm, method)
      uri = URI.parse(url)
      uri.user = @digest_auth[:user]
      uri.password = @digest_auth[:password]
      digest_auth = Net::HTTP::DigestAuth.new
      digest_auth.auth_header uri, realm, method.upcase
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
