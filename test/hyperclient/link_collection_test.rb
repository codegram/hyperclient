require_relative '../test_helper'
require 'hyperclient'

module Hyperclient
  describe LinkCollection do
    let(:entry_point) { stub('Entry point', config: { base_uri: '/' }) }

    let(:representation) do
      JSON.parse(File.read('test/fixtures/element.json'))
    end

    let(:links) do
      LinkCollection.new(representation['_links'], representation['_links']['curies'], entry_point)
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

    describe 'plain link' do
      let(:plain_link) { links.self }
      it 'must be correct' do
        plain_link._url.must_equal '/productions/1'
      end
    end

    describe 'templated link' do
      let(:templated_link) { links.filter }
      it 'must expand' do
        templated_link._expand(filter: 'gizmos')._url.must_equal '/productions/1?categories=gizmos'
      end
    end

    describe 'curied link collection' do
      let(:curied_link) { links['image:thumbnail'] }
      let(:curie) { links._curies['image'] }
      it 'must expand' do
        curied_link._expand(version: 'small')._url.must_equal '/images/thumbnails/small.jpg'
      end
      it 'exposes curie' do
        curie.expand('thumbnail').must_equal '/docs/images/thumbnail'
      end
    end

    describe 'array of links' do
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

    describe 'null link value' do
      let(:null_link) { links.null_link }
      it 'must be nil' do
        null_link.must_be_nil
      end
    end
  end
end
