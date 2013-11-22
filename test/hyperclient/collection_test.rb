require_relative '../test_helper'
require 'hyperclient/resource'

module Hyperclient
  describe Collection do
    let(:representation) do
      JSON.parse( File.read('test/fixtures/element.json'))
    end

    let(:collection) do
      Collection.new(representation)
    end

    it 'exposes the collection as methods' do
      collection.title.must_equal 'Real World ASP.NET MVC3'
      collection.description.must_match(/production/)
      collection.permitted.must_equal true
    end

    it 'exposes collection as a hash' do
      collection['title'].must_equal 'Real World ASP.NET MVC3'
      collection['description'].must_match(/production/)
      collection['permitted'].must_equal true
    end

    it 'correctly responds to methods' do
      collection.must_respond_to :title
    end

    it 'acts as enumerable' do
      names = collection.map do |name, value|
        name
      end

      names.must_equal ['_links', 'title', 'description', 'permitted', '_hidden_attribute', '_embedded']
    end

    describe '#to_hash' do
      it 'returns the wrapped collection as a hash' do
        collection.to_hash.must_be_kind_of Hash
      end
    end

    describe 'include?' do
      it 'returns true for keys that exist' do
        collection.include?('_links').must_equal true
      end

      it 'returns false for missing keys' do
        collection.include?('missing key').must_equal false
      end
    end
  end
end

