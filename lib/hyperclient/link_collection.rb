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
    #
    def initialize(collection, entry_point)
      raise "Invalid response for LinkCollection. The response was: #{collection.inspect}" if collection && !collection.respond_to?(:collect)

      @collection = Hash[
        (collection || {}).collect do |name, link_or_links|
          value = if link_or_links.class == Array
            link_or_links.collect do |link|
              Link.new(link, entry_point)
            end
          else
            Link.new(link_or_links, entry_point)
          end

          [name, value]
        end
      ]
    end
  end
end
