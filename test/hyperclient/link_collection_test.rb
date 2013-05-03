require_relative '../test_helper'
require 'hyperclient/link_collection'

module Hyperclient
  describe LinkCollection do
    let(:entry_point) { stub('Entry point', config: {base_uri: '/'}) }

    let(:representation) do
      JSON.parse( File.read('test/fixtures/element.json'))
    end

    let(:links) do
      LinkCollection.new(representation['_links'], entry_point)
    end

    it 'is a collection' do
      LinkCollection.ancestors.must_include Collection
    end

    it 'initializes the collection with links' do
      links.must_respond_to :filter
      links.must_respond_to :gizmos
    end

    it 'returns link objects for each link' do
      links.filter.must_be_kind_of Link
      links['self'].must_be_kind_of Link

      links.gizmos.must_be_kind_of Array
      links['gizmos'].must_be_kind_of Array
    end

    describe "array of links" do
      let(:gizmos) { links.gizmos }

      it 'should have 2 items' do
        gizmos.length.must_equal 2
      end

      it 'must be an array of Links' do
        gizmos.each do |link|
          link.must_be_kind_of Link
        end
      end
    end

    describe "null link value" do
      let(:null_link) { links.null_link }
      it 'must be nil' do
        null_link.must_be_nil
      end
    end
  end
end
