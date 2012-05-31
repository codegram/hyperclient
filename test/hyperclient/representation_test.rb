require_relative '../test_helper'
require 'hyperclient/representation'

module Hyperclient
  describe Representation do
    let (:representation) do
      Representation.new JSON.parse(File.read('test/fixtures/element.json'))
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

    describe 'url' do
      it 'returns the url of the resource grabbed from the representation' do
        representation.url.must_equal '/productions/1'
      end

      it 'returns nil when the representation does not include the resource url' do
        representation = Representation.new({_links: {media: {href: '/media/1'}}})

        representation.url.must_equal nil
      end
    end
  end
end
