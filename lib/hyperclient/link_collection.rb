require 'hyperclient/collection'
require 'hyperclient/link'
require 'hyperclient/curie'

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
    # collection - The Hash with the links.
    # curies - Link curies.
    # entry_point - The EntryPoint object to inject the configuration.
    def initialize(collection, curies, entry_point)
      fail "Invalid response for LinkCollection. The response was: #{collection.inspect}" if collection && !collection.respond_to?(:collect)

      @curies = (curies || {}).reduce({}) do |hash, curie_hash|
        curie = build_curie(curie_hash, entry_point)
        hash.update(curie.name => curie)
      end

      @collection = (collection || {}).reduce({}) do |hash, (name, link)|
        hash.update(name => build_link(name, link, @curies, entry_point))
      end
    end

    private

    # Internal: Creates links from the response hash.
    #
    # link_or_links - A Hash or an Array of hashes with the links to build.
    # entry_point - The EntryPoint object to inject the configuration.
    # curies - Optional curies for templated links.
    #
    # Returns a Link or an array of Links when given an Array.
    def build_link(name, link_or_links, curies, entry_point)
      return unless link_or_links
      if link_or_links.respond_to?(:to_ary)
        link_or_links.map do |link|
          build_link(name, link, curies, entry_point)
        end
      elsif (curie_parts = /(?<ns>[^:]+):(?<short_name>.+)/.match(name))
        curie = curies[curie_parts[:ns]]
        link_or_links['href'] = curie.expand(link_or_links['href']) if curie
        Link.new(name, link_or_links, entry_point)
      else
        Link.new(name, link_or_links, entry_point)
      end
    end

    # Internal: Creates a curie from the response hash.
    #
    # curie_hash - A Hash with the curie.
    # entry_point - The EntryPoint object to inject the configuration.
    #
    # Returns a Link or an array of Links when given an Array.
    def build_curie(curie_hash, entry_point)
      Curie.new(curie_hash, entry_point)
    end
  end
end
