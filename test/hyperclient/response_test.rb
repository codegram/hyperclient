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

      it 'does not inclide _embedded as attributes' do
        response.attributes.wont_include '_embedded'
      end
    end

    describe 'url' do
      it 'returns the url of the resource grabbed from the response' do
        response.url.must_equal '/productions/1'
      end
    end
  end
end
