require_relative '../test_helper'
require 'hyperclient/link_collection'

module Hyperclient
  describe LinkCollection do
    let(:representation) do
      JSON.parse( File.read('test/fixtures/element.json'))
    end

    let(:links) do
      LinkCollection.new(representation['_links'])
    end

    it 'is a collection' do
      LinkCollection.ancestors.must_include Collection
    end

    it 'initializes the collection with links' do
      links.must_respond_to :filter
    end

    it 'returns link objects for each link' do
      links.filter.must_be_kind_of Link
      links['self'].must_be_kind_of Link
    end
  end
end
