require_relative '../test_helper'
require 'hyperclient/response'

module Hyperclient
  describe Discoverer do
    before do
      Resource.entry_point = 'http://api.myexample.org/'
    end

    let (:discoverer) do
      Discoverer.new(JSON.parse(File.read('test/fixtures/element.json')))
    end

    describe 'links' do
      it 'discovers resoures from _links' do
        discoverer.links.must_include 'filter'
      end

      it 'initializes resources with its url' do
        discoverer.links['filter'].url.must_include '/productions/1?categories'
      end

      it 'does not set self as a resource' do
        discoverer.links.wont_include 'self'
      end
    end

    describe 'embedded' do
      it 'discovers resoures from _embedded' do
        discoverer.embedded.must_include 'episodes', 'author'
      end

      it 'initializes resources with the embedded data' do
        discoverer.embedded['author'].attributes.must_include 'name'
      end

      it 'also discovers collection resources' do
        discoverer.embedded['episodes'].length.must_equal 2
      end

      it 'initializes embedded collection resources' do
        episode = discoverer.embedded['episodes'].first

        episode.url.must_include '/episodes/1'
        episode.attributes.must_include 'title'
      end
    end
  end
end
