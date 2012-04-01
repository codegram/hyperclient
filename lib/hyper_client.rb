require "hyper_client/version"
require 'json'
require 'forwardable'
require 'httparty'

module HyperClient

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

    class Response
      def initialize(response)
        @response = response
      end

      def resources
        unless defined?(@resources)
          @resources = extract_resources_from('_links').merge(extract_resources_from('_embedded'))
        end
        @resources
      end

      def data
        @response.delete_if {|key, value| key =~ /^_/}
      end

      def url
        @response['_links']['self']['href']
      end

      private
      # Bonus points for refactoring this
      def extract_resources_from(selector)
        return {} if !@response || !@response.include?(selector)

        @response[selector].inject({}) do |resources, (name, response)|

          unless name == 'self'
            resource = if response.is_a?(Array)
                         response.map do |element|

                           if element.include?('href')
                             element = build_self_link_response(element['href'])
                           end

                           Resource.new(element)
                         end
                       else
                         if response.include?('href')
                           response = build_self_link_response(response['href'])
                         end
                         Resource.new(response)
                       end

            resources.update(name => resource)
          end
        resources
        end
      end

      def build_self_link_response(link)
        {'_links' => {'self' => {'href' => link}} }
      end
    end
  end
