require_relative '../test_helper'
require 'hyperclient'

module Hyperclient
  describe Collection do
    let(:representation) do
      JSON.parse(File.read('test/fixtures/element.json'))
    end

    let(:collection) do
      Collection.new(representation)
    end

    it 'exposes the collection as methods' do
      _(collection.title).must_equal 'Real World ASP.NET MVC3'
      _(collection.description).must_match(/production/)
      _(collection.permitted).must_equal true
    end

    it 'exposes collection as a hash' do
      _(collection['title']).must_equal 'Real World ASP.NET MVC3'
      _(collection['description']).must_match(/production/)
      _(collection['permitted']).must_equal true
    end

    it 'correctly responds to methods' do
      _(collection).must_respond_to :title
    end

    it 'acts as enumerable' do
      names = collection.map do |name, _value|
        name
      end

      _(names).must_equal %w[_links title description permitted _hidden_attribute _embedded]
    end

    describe '#to_hash' do
      it 'returns the wrapped collection as a hash' do
        _(collection.to_hash).must_be_kind_of Hash
      end
    end

    describe 'include?' do
      it 'returns true for keys that exist' do
        _(collection.include?('_links')).must_equal true
      end

      it 'returns false for missing keys' do
        _(collection.include?('missing key')).must_equal false
      end
    end

    describe '#fetch' do
      it 'returns the value for keys that exist' do
        _(collection.fetch('title')).must_equal 'Real World ASP.NET MVC3'
      end

      it 'raises an error for missing keys' do
        _(proc { collection.fetch('missing key') }).must_raise KeyError
      end

      describe 'with a default value' do
        it 'returns the value for keys that exist' do
          _(collection.fetch('title', 'default')).must_equal 'Real World ASP.NET MVC3'
        end

        it 'returns the default value for missing keys' do
          _(collection.fetch('missing key', 'default')).must_equal 'default'
        end
      end
    end
  end
end
