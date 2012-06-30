module Hyperclient
  # Public: This class acts as an interface to build Resources. It has a simple
  # identity map so a user can save HTTP calls when interacting with the same
  # resource.
  #
  # Examples
  #
  # ResourceFactory.resource('http://myapi.org/resource/1')
  # => #<Hyperclient::Resource url: 'http://myapi.org/resource/1'>
  #
  class ResourceFactory
    # Public: A factory method to build Resources. It will try to find a
    # Resource in the identity map or build a new one if does not exist.
    #
    # url - A String to identify the Resource
    # args - An Array to pass other arguments to the Resource initialization.
    #
    # Raises MissingURLException if no url given.
    # Returns a Resource.
    def self.resource(url, *args)
      raise MissingURLException.new(args) unless url

      identity_map.fetch(url) do |url|
        resource = Resource.new(url, *args)
        identity_map.update(url => resource)
        resource
      end
    end

    private
    # Internal: Returns a Hash that acts as identity map.
    def self.identity_map
      @identity_map ||= {}
    end
  end

  # Public: Exception that is raised when building a Resource without a URL.
  class MissingURLException < StandardError
    # Public: Initializes a MissingURLException
    #
    # args - An Array of the args the were to be used to build the Resource.
    def initialize(args)
      @args = args
    end

    # Public: Returns a String with the exception message.
    def message
      "Cannot build Resource without a URL, given args were: #{@args.inspect}"
    end
  end
end

require 'hyperclient/resource'
