require 'hyperclient/link'

# Public: The Hyperclient module has various methods to so you can setup your
# API client.
#
# Examples
#
#  options = {}
#  options[:headers] = {'accept-encoding' => 'deflate, gzip'}
#  options[:auth]    = {type: 'digest', user: 'foo', password: 'secret'}
#  options[:debug]   = true
#
#  Hyperclient::EntryPoint.new('http://my.api.org', options)
#
module Hyperclient
  class EntryPoint
    attr_accessor :config

    def initialize(entry_point, config = {})
      @config = config.update(base_uri: entry_point)
      @entry  = Link.new({'href' => entry_point}, self).resource
    end

    # Internal: Delegate the method to the API if it exists.
    #
    # This way we can call our API client with the resources name instead of
    # having to add the methods to it.
    def method_missing(method, *args, &block)
      if @entry.respond_to?(method)
        @entry.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      @entry.respond_to?(method.to_s)
    end
  end
end
