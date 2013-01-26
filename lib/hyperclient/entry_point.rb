require 'hyperclient/link'
require 'hyperclient/http'

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

    # Public: Returns the Hash with the configuration.
    attr_accessor :config

    # Public: Initializes an EntryPoint.
    #
    # url    - A String with the entry point of your API.
    # config - The Hash options used to setup the HTTP client (default: {})
    #          See HTTP for more documentation.
    def initialize(url, config = {})
      @config = config.update(base_uri: url)
    end

    def entry
      @entry ||= Link.new({'href' => config[:base_uri]}, self).resource
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

    def connection
      @connection ||= HTTP.new(config)
    end
  end
end
