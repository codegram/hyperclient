require 'hyperclient/link'

# Public: The Hyperclient module has various methods to so you can setup your
# API client.
#
# Examples
#
#  Hyperclient::EntryPoint.new('http://my.api.org', options)
#
module Hyperclient
  class EntryPoint
    def initialize(entry_point, http_options = {})
      @entry = Link.new({'href' => entry_point}).resource
      @http_options = http_options
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

    # Public: Sets the authentication options for your API client.
    #
    # type     - A String or Symbol with the authentication method. Can be either
    #            :basic or :digest.
    # user     - A String with the user.
    # password - A String with the password.
    #
    # Returns nothing.
    def auth(type, user, password)
      self.http_options({auth: {type: type, credentials: [user, password]}})
    end

    # Public: Sets the HTTP options that will be used to initialize
    # Hyperclient::HTTP.
    #
    # options - A Hash with options to pass to HTTP.
    #
    # Example:
    #
    #   http_options headers: {'accept-encoding' => 'deflate, gzip'}
    #
    # Returns a Hash.
    def http_options(options = {})
      @http_options.merge!(options)
    end
  end
end
