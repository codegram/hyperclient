# typed: strict
require 'faraday_middleware'
require 'faraday_hal_middleware'
require_relative '../faraday/connection'

module Hyperclient
  # Public: Exception that is raised when trying to modify an
  # already initialized connection.
  class ConnectionAlreadyInitializedError < StandardError
    # Public: Returns a String with the exception message.
    sig { returns(String) }
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
  #      conn.use Faraday::Request::OAuth
  #    end
  #    entry_point.headers['Access-Token'] = 'token'
  #  end
  #
  class EntryPoint < Link
    extend Forwardable
    extend T::Sig

    FaradayBlock = T.type_alias(T.proc.params(arg0: Faraday::Connection).returns(T.untyped))

    # Public: Delegates common methods to be used with the Faraday connection.
    def_delegators :connection, :basic_auth, :digest_auth, :token_auth, :params, :params=

    # Public: Initializes an EntryPoint.
    #
    # url    - A String with the entry point of your API.
    sig { params(url: String).void }
    def initialize(url, &_block)
      @link = T.let({ 'href' => url }, T::Hash[String, String])
      @entry_point = T.let(self, EntryPoint)
      @options = T.let({}, Hash)
      @connection = T.let(nil, T.nilable(Faraday::Connection))
      @resource = nil
      @key = nil
      @uri_variables = nil
      @faraday_block = T.let(nil, T.nilable(FaradayBlock))
      @faraday_options = T.let(nil, T.nilable(T::Hash[Symbol, T.untyped]))
      @headers = T.let(nil, T.nilable(T::Hash[String, String]))
      yield self if block_given?
    end

    # Public: A Faraday connection to use as a HTTP client.
    #
    # options - A Hash containing additional options to pass to Farday. Use
    # {default: false} if you want to skip using default Faraday options set by
    # Hyperclient.
    #
    # Returns a Faraday::Connection.
    sig { params(options: Hash).returns(Faraday::Connection) }
    def connection(options = {}, &block)
      @faraday_options ||= options.dup
      if block_given?
        raise ConnectionAlreadyInitializedError if @connection

        @faraday_block = if @faraday_options.delete(:default) == false
                           block
                         else
                           lambda do |conn|
                             default_faraday_block.call conn
                             yield conn
                           end
                         end
      else
        @connection ||= Faraday.new(_url, faraday_options, &faraday_block)
      end
    end

    # Public: Headers included with every API request.
    #
    # Returns a Hash.
    sig { returns(T::Hash[String, String]) }
    def headers
      return @connection.headers if @connection

      @headers ||= default_headers
    end

    # Public: Set headers.
    #
    # value    - A Hash containing headers to include with every API request.
    sig { params(value: T::Hash[String, String]).void }
    def headers=(value)
      raise ConnectionAlreadyInitializedError if @connection

      @headers = value
    end

    # Public: Options passed to Faraday
    #
    # Returns a Hash.
    sig { returns(T::Hash[Symbol, T.untyped]) }
    def faraday_options
      (@faraday_options ||= {}).merge(headers: headers)
    end

    # Public: Set Faraday connection options.
    #
    # value    - A Hash containing options to pass to Faraday
    sig { params(value: T::Hash[Symbol, T.untyped]).void }
    def faraday_options=(value)
      raise ConnectionAlreadyInitializedError if @connection

      @faraday_options = value
    end

    # Public: Faraday block used with every API request.
    #
    # Returns a Proc.
    sig { returns(FaradayBlock) }
    def faraday_block
      @faraday_block ||= default_faraday_block
    end

    # Public: Set a Faraday block to use with every API request.
    #
    # value    - A Proc accepting a Faraday::Connection.
    sig { params(value: FaradayBlock).returns(FaradayBlock) }
    def faraday_block=(value)
      raise ConnectionAlreadyInitializedError if @connection

      @faraday_block = value
    end

    # Public: Read/Set options.
    #
    # value    - A Hash containing the client options.
    sig { returns(Hash) }
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
    sig { returns(FaradayBlock) }
    def default_faraday_block
      lambda do |connection|
        connection.use Faraday::Response::RaiseError
        connection.use FaradayMiddleware::FollowRedirects
        connection.request :hal_json
        connection.response :hal_json, content_type: /\bjson$/
        connection.adapter :net_http
        connection.options.params_encoder = Faraday::FlatParamsEncoder
      end
    end

    # Internal: Returns the default headers to initialize the Faraday connection.
    # The default headers et the Content-Type and Accept to application/json.
    #
    # Returns a Hash.
    sig { returns(T::Hash[String, String]) }
    def default_headers
      { 'Content-Type' => 'application/hal+json', 'Accept' => 'application/hal+json,application/json' }
    end
  end
end
