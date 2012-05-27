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

      it 'dos not include _links as attributes' do
        response.attributes.wont_include '_links'
      end

      it 'does not include _embedded as attributes' do
        response.attributes.wont_include '_embedded'
      end
    end

    describe 'resources' do
      it 'returns a Hash with linked resources' do
        response.resources.keys.must_include 'filter'
      end

      it 'returns a Hash with embedded resources' do
        response.resources.keys.must_include 'author', 'episodes'
      end
    end

    describe 'url' do
      it 'returns the url of the resource grabbed from the response' do
        response.url.must_equal '/productions/1'
      end
    end

    describe 'has_url?' do
      it 'returns true when the response has the url to the resource' do
        response.has_url?.must_equal true
      end

      it 'returns false when the response does not include the resource url' do
        response = Response.new({_links: {media: {href: '/media/1'}}})

        response.has_url?.must_equal false
      end
    end
  end
end
