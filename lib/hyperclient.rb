# Public: Hyperclient namespace.
#
module Hyperclient
  def self.new(url)
    Hyperclient::EntryPoint.new(url)
  end
end

require 'hyperclient/entry_point'
require "hyperclient/version"
