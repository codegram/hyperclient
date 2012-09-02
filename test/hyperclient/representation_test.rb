require_relative '../test_helper'
require 'hyperclient/representation'

module Hyperclient
  describe Representation do
    let (:representation) do
      Representation.new JSON.parse(File.read('test/fixtures/element.json'))
    end

    describe 'intialize' do
      it 'handles non-hash representations' do
        representation = Representation.new '{"title": "Hello world"}'

        representation.attributes['title'].must_equal 'Hello world'
      end

      it 'does not raise when non-JSON response is given' do
        representation = Representation.new 'This is not JSON'

        representation.attributes.must_equal({})
      end
    end

    describe 'attributes' do
      it 'returns the resource attributes' do
        representation.attributes['title'].must_equal 'Real World ASP.NET MVC3'
      end

      it 'does not include _links as attributes' do
        representation.attributes.wont_include '_links'
      end

      it 'does not include _embedded as attributes' do
        representation.attributes.wont_include '_embedded'
      end
    end

    describe 'links' do
      it 'returns a collection of links' do
        representation.links.to_a.length.must_equal 2
      end

      it 'exposes links as methods' do
        representation.links.respond_to?(:filter).must_equal true
      end

      it 'makes links also accessible by key' do
        representation.links['self'].wont_be_nil
      end

      it 'sets links as templated' do
        representation.links.filter.templated?.must_equal true
      end
    end

    describe 'embedded' do
      it 'returns resources included in the _embedded section' do
        representation.embedded.author.must_be_kind_of Resource
        representation.embedded.episodes.first.must_be_kind_of Resource
        representation.embedded.episodes.last.must_be_kind_of Resource
      end
    end
  end
end
