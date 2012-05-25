require 'hyperclient/discoverer'

module Hyperclient
  class Response
    def initialize(response)
      @response = response
    end

    def resources
      discoverer = Discoverer.new(@response)
      discoverer.resources
    end

    def data
      @response.delete_if {|key, value| key =~ /^_/}
    end

    def url
      @response['_links']['self']['href']
    end
  end
end
