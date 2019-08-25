require 'hyperclient/collection'
require 'hyperclient/link'
require 'hyperclient/attributes'
require 'hyperclient/curie'
require 'hyperclient/entry_point'
require 'hyperclient/link_collection'
require 'hyperclient/resource'
require 'hyperclient/resource_collection'
require 'hyperclient/version'
require 'hyperclient/railtie' if defined?(Rails)

# Public: Hyperclient namespace.
#
module Hyperclient
  URL_TO_ENDPOINT_MAPPING = { }

  # Public: Convenience method to create new EntryPoints.
  #
  # url - A String with the url of the API.
  #
  # Returns a Hyperclient::EntryPoint
  def self.new(url, &block)
    URL_TO_ENDPOINT_MAPPING[url] = Hyperclient::EntryPoint.new(url, &block)
  end

  def self.lookup_entry_point(uri)
    URL_TO_ENDPOINT_MAPPING[uri] || raise(ArgumentError, "Entry point not registered for #{uri}")
  end
end
