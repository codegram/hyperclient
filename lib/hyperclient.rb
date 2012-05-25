require "hyperclient/version"
require 'json'
require 'forwardable'
require 'httparty'

module Hyperclient

  def self.included(base)
    base.send :extend, ClassMethods
  end

  def resources
    response = Net::HTTP.get(self.class.entry_point)
    json = JSON.parse(response)

    Resource.base_uri = self.class.entry_point
    @api = Resource.new(json)
    @api.resources
  end

  module ClassMethods
    def entry_point(uri=nil)
      return @entry_point unless uri
      @entry_point = URI(uri)
    end
  end

end

require 'hyperclient/resource'
