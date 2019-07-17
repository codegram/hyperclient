# typed: strict
require 'sorbet-runtime'

require 'hyperclient/collection'
require 'hyperclient/link'
require 'hyperclient/attributes'
require 'hyperclient/curie'
require 'hyperclient/entry_point'
require 'hyperclient/link_collection'
require 'hyperclient/resource'
require 'hyperclient/resource_collection'
require 'hyperclient/version'

# Public: Hyperclient namespace.
#
module Hyperclient
  # Public: Convenience method to create new EntryPoints.
  #
  # url - A String with the url of the API.
  #
  # Returns a Hyperclient::EntryPoint
  sig {params(url: String).returns(Hyperclient::EntryPoint)}
  def self.new(url, &block)
    Hyperclient::EntryPoint.new(url, &block)
  end
end
