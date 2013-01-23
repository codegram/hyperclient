require 'faraday'
require 'faraday_middleware'
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
      process_request :get
    end

    # Public: Sends a POST request the the resource url.
    #
    # params - A Hash to send as POST params
    #
    # Returns: A HTTParty::Response
    def post(params)
      process_request(:post, params)
    end

    # Public: Sends a PUT request the the resource url.
    #
    # params - A Hash to send as PUT params
    #
    # Returns: A HTTParty::Response
    def put(params)
      process_request(:put, params)
    end

    # Public: Sends an OPTIONS request the the resource url.
    #
    # Returns: A HTTParty::Response
    def options
      process_request(:options)
    end

    # Public: Sends a HEAD request the the resource url.
    #
    # Returns: A HTTParty::Response
    def head
      process_request(:head)
    end

    # Public: Sends a DELETE request the the resource url.
    #
    # Returns: A HTTParty::Response
    def delete
      process_request(:delete)
    end

    def process_request(method, params = nil)
      faraday.run_request(method, url, params, faraday.headers)
    end

    def faraday
      @faraday ||= Faraday.new(faraday_options, &faraday_block)
    end

    def faraday_options
      default_options = {url: @base_uri, headers: (headers) }
      default_options.merge(@faraday_options)
    end

    def headers
      {'Content-Type' => 'application/json'}.merge(@config[:headers] || {})
    end

    def faraday_block
      return @faraday_block unless @faraday_block.nil?

      lambda do |faraday|
        faraday.request  :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter :net_http
      end
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
      faraday.builder.insert(0, Faraday::Request::DigestAuth, options.fetch(:user), options.fetch(:password))
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

module Faraday
  class Request::DigestAuth < Faraday::Middleware
    def initialize(app, user, password)
      super(app)
      @user, @password = user, password
    end

    def call(env)
      handshake(env)
      @app.call(env)
    end

    def handshake(env)
      return if env[:request_headers].include?('Authorization')

      env_without_body = env.dup
      env_without_body.delete(:body)
      response = @app.call(env_without_body)

      env[:request_headers]['Authorization'] = digest_auth_header(response)
    end

    def digest_auth_header(response)
      uri = response.env[:url]
      uri.user = @user
      uri.password = @password
      realm = response.headers['www-authenticate']
      digest_auth = Net::HTTP::DigestAuth.new
      digest_auth.auth_header(uri, realm, response.env[:method].to_s.upcase)
    end
  end
end
