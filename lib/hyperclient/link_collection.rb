require 'hyperclient/collection'
require 'hyperclient/link'

module Hyperclient
  # Public: A wrapper class to easily acces the links in a  Resource.
  #
  # Examples
  #
  #   resource.links['author']
  #   resource.links.author
  #
  class LinkCollection < Collection
    # Public: Initializes a LinkCollection.
    #
    # collection  - The Hash with the links.
    # entry_point - The EntryPoint object to inject the configuration.
    def initialize(collection, entry_point)
      raise "Invalid response for LinkCollection. The response was: #{collection.inspect}" if collection && !collection.respond_to?(:collect)

      @collection = (collection || {}).inject({}) do |hash, (name, link)|
        hash.update(name => build_link(link, entry_point))
      end
    end

    private
    # Internal: Creates links from the response hash.
    #
    # link_or_links - A Hash or an Array of hashes with the links to build.
    # entry_point   - The EntryPoint object to inject the configuration.
    #
    # Returns a Link or an array of Links when given an Array.
    def build_link(link_or_links, entry_point)
      return unless link_or_links
      return Link.new(link_or_links, entry_point) unless link_or_links.respond_to?(:to_ary)

      link_or_links.collect do |link|
        build_link(link, entry_point)
      end
    end
  end
end
