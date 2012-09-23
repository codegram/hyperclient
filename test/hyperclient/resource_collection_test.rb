require_relative '../test_helper'
require 'hyperclient/resource_collection'

module Hyperclient
  describe ResourceCollection do
    let(:entry_point) { stub('Entry point', config: {base_uri: '/'}) }

    let(:representation) do
      JSON.parse( File.read('test/fixtures/element.json'))
    end

    let(:resources) do
      ResourceCollection.new(representation['_embedded'], entry_point)
    end

    it 'is a collection' do
      ResourceCollection.ancestors.must_include Collection
    end

    it 'initializes the collection with resources' do
      resources.must_respond_to :author
      resources.must_respond_to :episodes
    end

    it 'returns resource objects for each resource' do
      resources.author.must_be_kind_of Resource
    end

    it 'also builds arras of resource' do
      resources.episodes.must_be_kind_of Array
      resources.episodes.first.must_be_kind_of Resource
    end
  end
end
