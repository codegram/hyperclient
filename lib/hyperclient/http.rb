require 'faraday'
require 'faraday_middleware'
require 'json'
require 'logger'
require 'net/http/digest_auth'

module Hyperclient
  # Internal: This class wrapps HTTParty and performs the HTTP requests for a
  # resource.
  class HTTP
    attr_reader :options
    attr_writer :connection, :faraday_options, :faraday_block
    attr_accessor :faraday_block, :headers

    # Public: Initializes the HTTP agent.
    #
    # options - A Hash with the configuration of the HTTP connection.
    #          :base_uri - The base uri String
    #          :headers - The Hash with the headers of the connection.
    #          :auth    - The Hash with the authentication options:
    #            :type     - A String or Symbol to set the authentication type.
    #                        Allowed values are :digest or :basic.
    #            :user     - A String with the user.
    #            :password - A String with the user.
    #          :faraday_options - A Hash that will be passed to Faraday.new (optional).
    #                             Can additionally include a :block => <Proc> that is also
    #                             passed to Faraday.
    #
    def initialize(options)
      raise "Invalid options for HTTP" unless valid_options?(options)

      @options  = options

      @headers = default_headers.merge(@options.fetch(:headers, {}))
      extract_authentication_from_options(@options.fetch(:auth, {}))

      @base_uri = @options.fetch(:base_uri)
    end

    # Public: Sends a GET request the the resource url.
    #
    # Returns: The parsed response.
    def get(path)
      process_request(:get, path)
    end

    # Public: Sends a POST request the the resource url.
    #
    # params - A Hash to send as POST params
    #
    # Returns: A HTTParty::Response
    def post(path, params)
      process_request(:post, path, params)
    end

    # Public: Sends a PUT request the the resource url.
    #
    # params - A Hash to send as PUT params
    #
    # Returns: A HTTParty::Response
    def put(path, params)
      process_request(:put, path, params)
    end

    # Public: Sends an OPTIONS request the the resource url.
    #
    # Returns: A HTTParty::Response
    def options(path)
      process_request(:options, path)
    end

    # Public: Sends a HEAD request the the resource url.
    #
    # Returns: A HTTParty::Response
    def head(path)
      process_request(:head, path)
    end

    # Public: Sends a DELETE request the the resource url.
    #
    # Returns: A HTTParty::Response
    def delete(path)
      process_request(:delete, path)
    end

    def connection
      @connection ||= Faraday.new(faraday_options, &faraday_block)
    end

    def basic_auth(user, password)
      connection.basic_auth(user, password)
    end

    def digest_auth(user, password)
      connection.builder.insert(0, Faraday::Request::DigestAuth, user, password)
    end

    def faraday_options
      @faraday_options ||= default_faraday_options.merge(@options.fetch(:faraday_options, {}))
    end

    def faraday_block
      @faraday_block ||= faraday_options.delete(:block) || default_faraday_block
    end

    def log!(logger = Logger.new)
      connection.response :logger, logger
    end

    private
    def process_request(method, path, params = nil)
      connection.run_request(method, path, params, headers)
    end

    def default_faraday_options
      {url: @base_uri}
    end

    def default_faraday_block
      lambda do |faraday|
        faraday.request  :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter :net_http
      end
    end

    def default_headers
      {'Content-Type' => 'application/json'}
    end

    # Internal: Sets the authentication method for HTTParty.
    #
    # options - An options Hash to set the authentication options.
    #
    # Returns nothing.
    def extract_authentication_from_options(options)
      return unless (options.keys & [:type, :user, :password]).length == 3

      auth_method = options[:type].to_s + '_auth'
      send(auth_method, options[:user], options[:password])
    end

    def valid_options?(options)
      options && options.respond_to?(:include?) && options.include?(:base_uri)
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
