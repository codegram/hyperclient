require 'hyperclient/collection'

module Hyperclient
  # Public: A wrapper class to easily acces the attributes in a Resource.
  #
  # Examples
  #
  #   resource.attributes['title']
  #   resource.attributes.title
  #
  class Attributes < Collection
    # Public: Initializes the Attributes of a Resource.
    #
    # representation - The hash with the HAL representation of the Resource.
    #
    def initialize(representation)
      @collection = representation.delete_if {|key, value| key =~ /^_/}
    end
  end
end
