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
    # Public: Initializes an EntryPoint.
    #
    # url    - A String with the entry point of your API.
    def initialize(url)
      @link = {'href' => url}
      @entry_point = self
    end

    def connection
      @connection ||= Faraday.new(url, {headers: default_headers}, &default_faraday_block)
    end

    private
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
  end
end
