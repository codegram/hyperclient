# Public: The Hyperclient module has various methods to so you can setup your
# API client.
#
# Examples
#
#   class MyAPI
#     extend Hyperclient
#
#     entry_point 'http://api.myapp.com'
#   end
#
module Hyperclient
  # Internal: Extend the parent class with our class methods.
  def self.included(base)
    base.send :extend, ClassMethods
  end

  # Public: Initializes the API with the entry point.
  def entry
    @entry ||= Resource.new('/', resource_options)
  end

  # Internal: Delegate the method to the API if it exists.
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

  module ClassMethods
    # Public: Set the entry point of your API.
    #
    # Returns nothing.
    def entry_point(url)
      Resource.entry_point = url
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
      http_options({auth: {type: type, credentials: [user, password]}})
    end

    # Public: Returns a Hash with the HTTP options that will be used to
    # initialize Hyperclient::HTTP.
    def http_options(options = {})
      @@http_options ||= {}
      @@http_options.merge!(options)

      {http: @@http_options}
    end
  end

  private
  # Internal: Returns a Hash with the options to initialize the entry point
  # Resource.
  def resource_options
    {name: 'Entry point'}.merge(self.class.http_options)
  end
end

require 'hyperclient/resource'
require "hyperclient/version"
