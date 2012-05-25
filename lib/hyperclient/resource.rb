require 'hyperclient/response'

module Hyperclient
  class Resource
    extend Forwardable
    def_delegators :@response, :data, :resources

    def initialize(response)
      @response = Response.new(response)
      create_resources_accessors
    end

    def get
      HTTParty.get(url.to_s)
    end

    def post(params)
      HTTParty.post(url.to_s, params)
    end

    def put(params)
      HTTParty.put(url.to_s, params)
    end

    def options
      HTTParty.options(url.to_s)
    end

    def head
      HTTParty.head(url.to_s)
    end

    def delete
      HTTParty.delete(url.to_s)
    end

    def base_uri
      @@base_uri
    end

    def self.base_uri=(value)
      @@base_uri = URI(value)
    end

    def url
      base_uri.merge(@response.url)
    end

    private

    def create_resources_accessors
      @response.resources.each do |name, resource|
        self.class.class_eval do
          define_method "#{name}" do
            @response.resources.fetch("#{name}")
          end
        end
      end
    end
  end
end
