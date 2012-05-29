require_relative '../test_helper'
require 'hyperclient/response'

module Hyperclient
  describe Response do
    let (:response) do
      Response.new JSON.parse(File.read('test/fixtures/element.json'))
    end

    describe 'attributes' do
      it 'returns the resource attributes' do
        response.attributes['title'].must_equal 'Real World ASP.NET MVC3'
      end

      it 'does not include _links as attributes' do
        response.attributes.wont_include '_links'
      end

      it 'does not include _embedded as attributes' do
        response.attributes.wont_include '_embedded'
      end
    end

    describe 'links' do
      it 'returns resources included in the _links section' do
        response.links.filter.must_be_kind_of Resource
      end
    end

    describe 'resources' do
      it 'returns resources included in the _embedded section' do
        response.resources.author.must_be_kind_of Resource
        response.resources.episodes.first.must_be_kind_of Resource
        response.resources.episodes.last.must_be_kind_of Resource
      end
    end

    describe 'url' do
      it 'returns the url of the resource grabbed from the response' do
        response.url.must_equal '/productions/1'
      end

      it 'returns nil when the response does not include the resource url' do
        response = Response.new({_links: {media: {href: '/media/1'}}})

        response.url.must_equal nil
      end
    end
  end
end
