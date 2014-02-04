require 'hyperclient/link'
require 'faraday_middleware'
require_relative '../faraday/connection'

module Hyperclient
  # Public: The EntryPoint is the main public API for Hyperclient. It is used to
  # initialize an API client and setup the configuration.
  #
  # Examples
  #
  #  client = Hyperclient::EntryPoint.new('http://my.api.org')
  #
  class EntryPoint < Link
    extend Forwardable
    # Public: Delegates common methods to be used with the Faraday connection.
    def_delegators :connection, :basic_auth, :digest_auth, :token_auth, :headers, :headers=, :params, :params=

    # Public: Initializes an EntryPoint.
    #
    # url    - A String with the entry point of your API.
    def initialize(url, &block)
      @link = {'href' => url}
      @entry_point = self
      @faraday_block = block if block_given?
    end

    # Public: A Faraday connection to use as a HTTP client.
    #
    # Returns a Faraday::Connection.
    def connection
      block = @faraday_block || default_faraday_block
      @connection ||= Faraday.new(url, {headers: default_headers}, &block)
    end

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
      lambda do |faraday|
        faraday.request  :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter :net_http
      end
    end

    # Internal: Returns the default headers to initialize the Faraday connection.
    # The default headers et the Content-Type and Accept to application/json.
    #
    # Returns a Hash.
    def default_headers
      {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
    end
  end
end
