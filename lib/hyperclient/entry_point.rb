require 'faraday/follow_redirects'
require 'faraday_hal_middleware'

module Hyperclient
  # Public: Exception that is raised when trying to modify an
  # already initialized connection.
  class ConnectionAlreadyInitializedError < StandardError
    # Public: Returns a String with the exception message.
    def message
      'The connection has already been initialized.'
    end
  end

  # Public: The EntryPoint is the main public API for Hyperclient. It is used to
  # initialize an API client and setup the configuration.
  #
  # Examples
  #
  #  client = Hyperclient::EntryPoint.new('http://my.api.org')
  #
  #  client = Hyperclient::EntryPoint.new('http://my.api.org') do |entry_point|
  #    entry_point.connection do |conn|
  #      conn.use Faraday::Request::Instrumentation
  #    end
  #    entry_point.headers['Access-Token'] = 'token'
  #  end
  #
  class EntryPoint < Link
    extend Forwardable

    # Public: Delegates common methods to be used with the Faraday connection.
    def_delegators :connection, :params, :params=

    # Public: Initializes an EntryPoint.
    #
    # url    - A String with the entry point of your API.
    def initialize(url, &_block)
      @link = { 'href' => url }
      @entry_point = self
      @options = {}
      @connection = nil
      @resource = nil
      @key = nil
      @uri_variables = nil
      yield self if block_given?
    end

    # Public: A Faraday connection to use as a HTTP client.
    #
    # options - A Hash containing additional options to pass to Farday. Use
    # {default: false} if you want to skip using default Faraday options set by
    # Hyperclient.
    #
    # Returns a Faraday::Connection.
    def connection(options = {}, &block)
      @faraday_options ||= options.dup
      if block_given?
        raise ConnectionAlreadyInitializedError if @connection

        @faraday_block = if @faraday_options.delete(:default) == false
                           block
                         else
                           lambda do |conn|
                             default_faraday_block.call(conn, &block)
                           end
                         end
      else
        @connection ||= Faraday.new(_url, faraday_options, &faraday_block)
      end
    end

    # Public: Headers included with every API request.
    #
    # Returns a Hash.
    def headers
      return @connection.headers if @connection

      @headers ||= default_headers
    end

    # Public: Set headers.
    #
    # value    - A Hash containing headers to include with every API request.
    def headers=(value)
      raise ConnectionAlreadyInitializedError if @connection

      @headers = value
    end

    # Public: Options passed to Faraday
    #
    # Returns a Hash.
    def faraday_options
      (@faraday_options ||= {}).merge(headers: headers)
    end

    # Public: Set Faraday connection options.
    #
    # value    - A Hash containing options to pass to Faraday
    def faraday_options=(value)
      raise ConnectionAlreadyInitializedError if @connection

      @faraday_options = value
    end

    # Public: Faraday block used with every API request.
    #
    # Returns a Proc.
    def faraday_block
      @faraday_block ||= default_faraday_block
    end

    # Public: Set a Faraday block to use with every API request.
    #
    # value    - A Proc accepting a Faraday::Connection.
    def faraday_block=(value)
      raise ConnectionAlreadyInitializedError if @connection

      @faraday_block = value
    end

    # Public: Read/Set options.
    #
    # value    - A Hash containing the client options.
    attr_accessor :options

    private

    # Internal: Returns a block to initialize the Faraday connection. The
    # default block includes a middleware to encode requests as JSON, a
    # response middleware to parse JSON responses and sets the adapter as
    # NetHttp.
    #
    # These middleware can always be changed by accessing the Faraday
    # connection.
    #
    # Returns a block.
    def default_faraday_block
      lambda do |connection, &block|
        connection.use Faraday::Response::RaiseError
        connection.use Faraday::FollowRedirects::Middleware
        connection.request :hal_json
        connection.response :hal_json, content_type: /\bjson$/

        block&.call(connection)

        connection.adapter :net_http
        connection.options.params_encoder = Faraday::FlatParamsEncoder
      end
    end

    # Internal: Returns the default headers to initialize the Faraday connection.
    # The default headers et the Content-Type and Accept to application/json.
    #
    # Returns a Hash.
    def default_headers
      { 'Content-Type' => 'application/hal+json', 'Accept' => 'application/hal+json,application/json' }
    end
  end
end
