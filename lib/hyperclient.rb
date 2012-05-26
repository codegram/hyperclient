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

  private
  # Private: Initializes the API with the entry point.
  def api
    @api = Resource.new('/') unless @api
    @api
  end

  # Private: Delegate the method to the API if it exists.
  #
  # This way the we can call our API client with the resources name instead of
  # having to add the methods to it.
  def method_missing(method, *args, &block)
    if api.respond_to?(method)
      api.send(method, *args, &block)
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
  end
end

require 'hyperclient/resource'
require "hyperclient/version"
