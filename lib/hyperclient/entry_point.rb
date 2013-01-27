require 'hyperclient/link'
require 'faraday_middleware'
require 'faraday/connection'

module Hyperclient
  # Public: The EntryPoint is the main public API for Hyperclient. It is used to
  # initialize an API client and setup the configuration.
  #
  # Examples
  #
  #  options = {}
  #  options[:headers] = {'accept-encoding' => 'deflate, gzip'}
  #  options[:auth]    = {type: 'digest', user: 'foo', password: 'secret'}
  #  options[:debug]   = true
  #
  #  client = Hyperclient::EntryPoint.new('http://my.api.org', options)
  #
  class EntryPoint
    # Public: Initializes an EntryPoint.
    #
    # url    - A String with the entry point of your API.
    def initialize(url)
      @url = url
    end

    def entry
      @entry ||= Link.new({'href' => @url}, self).resource
    end

    def connection
      @connection ||= Faraday.new(@url, {headers: default_headers}, &default_faraday_block)
    end

    # Internal: Delegate the method to the entry point Resource if it exists.
    #
    # This way we can call our API client with the resources name instead of
    # having to add the methods to it.
    def method_missing(method, *args, &block)
      if entry.respond_to?(method)
        entry.send(method, *args, &block)
      else
        super
      end
    end

    # Internal: Accessory method to allow the entry point respond to the
    # methods that will hit method_missing.
    def respond_to_missing?(method, include_private = false)
      entry.respond_to?(method.to_s)
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
