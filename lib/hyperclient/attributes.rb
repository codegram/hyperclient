require 'hyperclient/collection'

module Hyperclient
  class Attributes < Collection
    def initialize(representation)
      @collection = representation.delete_if {|key, value| key =~ /^_/}
    end
  end
end
