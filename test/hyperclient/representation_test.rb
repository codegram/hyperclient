require_relative '../test_helper'
require 'hyperclient/representation'

module Hyperclient
  describe Representation do
    let (:representation) do
      Representation.new JSON.parse(File.read('test/fixtures/element.json'))
    end

    describe 'intialize' do
      it 'handles non-hash representations' do
        representation = Representation.new '{"_links": {"self": {"href": "/productions/1"}}}'

        representation.url.must_equal '/productions/1'
      end

      it 'does not raise when non-JSON response is given' do
        representation = Representation.new 'This is not JSON'

        representation.url.must_equal nil
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
      it 'returns resources included in the _links section' do
        representation.links.filter.must_be_kind_of Resource
      end
    end

    describe 'resources' do
      it 'returns resources included in the _embedded section' do
        representation.resources.author.must_be_kind_of Resource
        representation.resources.episodes.first.must_be_kind_of Resource
        representation.resources.episodes.last.must_be_kind_of Resource
      end
    end
  end
end
