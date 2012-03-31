require "hyper_client/version"
require 'json'
require 'forwardable'

module HyperClient

  def self.included(base)
    base.send :extend, ClassMethods
  end

  def resources
    response = Net::HTTP.get(self.class.entry_point)
    json = JSON.parse(response)

    @entry_resource = Resource.new(self.class.entry_point.to_s, json)
    @entry_resource.resources
  end

  module ClassMethods
    def entry_point(uri=nil)
      return @entry_point unless uri
      @entry_point = URI(uri)
    end
  end

  class Resource
    extend Forwardable
    def_delegators :@response, :data, :resources

    attr_reader :url

    def initialize(url, response = nil)
      @url = URI(url)
      @url.merge!(@response['_links']['self']['href']) if @response

      @response = Response.new(response, @url)
      create_resources_accessors
    end

    def get
      Net::HTTP.get(@url)
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

  class Response
    def initialize(response, url)
      @response = response
      @url = url
      @resources = {}
    end

    def resources
      @resources.merge(links_resources).merge(embedded_resources)
    end

    def data
      @response.delete_if {|key, value| key =~ /^_/}
    end

    private
    def links_resources
      return {} if !@response || !@response.include?('_links')

      @response['_links'].inject({}) do |resources, (name, link)|
        unless name == 'self'
          if link.is_a?(Array)
            collection = link.map do |element_link|
              url = @url.merge(element_link['href'])
              Resource.new(url)
            end
            resources.update(name => collection)
          else
            url = @url.merge(link['href'])
            resources.update(name => Resource.new(url))
          end
        end
        resources
      end
    end

    def embedded_resources
      return {} if !@response || !@response.include?('_embedded')

      @response['_embedded'].inject({}) do |resources, (name, response)|
        if response.is_a?(Array)
          collection = response.map do |element_response|
            Resource.new(@url, element_response)
          end
          resources.update(name => collection)
        else
          resources.update(name => Resource.new(@url, response))
        end

        resources
      end
    end
  end
end
