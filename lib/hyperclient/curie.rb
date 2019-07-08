# frozen_string_literal: true

module Hyperclient
  # Internal: Curies are named tokens that you can define in the document and use
  # to express curie relation URIs in a friendlier, more compact fashion.
  #
  class Curie
    # Public: Initializes a new Curie.
    #
    # curie_hash  - The String with the URI of the curie.
    # entry_point - The EntryPoint object to inject the configuration.
    def initialize(curie_hash, entry_point)
      @curie_hash = curie_hash
      @entry_point = entry_point
    end

    # Public: Indicates if the curie is an URITemplate or a regular URI.
    #
    # Returns true if it is templated.
    # Returns false if it not templated.
    def templated?
      !!@curie_hash['templated']
    end

    # Public: Returns the name property of the Curie.
    def name
      @curie_hash['name']
    end

    # Public: Returns the href property of the Curie.
    def href
      @curie_hash['href']
    end

    def inspect
      "#<#{self.class.name} #{@curie_hash}>"
    end

    # Public: Expands the Curie when is templated with the given variables.
    #
    # rel - The String rel to expand.
    #
    # Returns a new expanded url.
    def expand(rel)
      return rel unless rel && templated?

      href&.gsub('{rel}', rel)
    end
  end
end
