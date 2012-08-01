require_relative '../test_helper'
require 'pry'
require 'hyperclient/representation'

module Hyperclient
  describe Discoverer do
    before do
      Resource.entry_point = 'http://api.myexample.org/'
    end

    let (:representation) do
      JSON.parse(File.read('test/fixtures/element.json'))
    end

    describe 'each' do
      it 'iterates between resources' do
        discoverer = Discoverer.new(representation['_links'])

        discoverer.each do |resource|
          resource.must_be_kind_of Resource
        end
      end
    end

    describe '[]' do
      it 'fetches a resource' do
        discoverer = Discoverer.new(representation['_links'])

        discoverer['filter'].must_be_kind_of Resource
      end
    end

    describe 'uri_templates' do
      it 'expands uri templates with given args' do
        discoverer = Discoverer.new(representation['_links'])

        url = discoverer.filter({filter: 'some_category'}).url

        url.must_match 'categories=some_category'
      end
    end

    describe 'resources' do
      it 'does not include self as a resource' do
        discoverer = Discoverer.new(representation['_links'])

        lambda { discoverer.self }.must_raise NoMethodError
      end

      it 'builds single resources' do
        discoverer = Discoverer.new(representation['_links'])

        discoverer.filter.must_be_kind_of Resource
      end

      it 'builds collection resources' do
        discoverer = Discoverer.new(representation['_embedded'])

        discoverer.episodes.must_be_kind_of Array
      end

      it 'also builds elements in collection resources' do
        discoverer = Discoverer.new(representation['_embedded'])

        discoverer.episodes.first.must_be_kind_of Resource
      end

      it 'initializes resources with its URL' do
        discoverer = Discoverer.new(representation['_links'])

        discoverer.filter.url.wont_be_empty
      end

      it 'initializes resources with the representation' do
        discoverer = Discoverer.new(representation['_embedded'])

        discoverer.author.attributes.wont_be_empty
      end

      it 'initializes resources with its name' do
        discoverer = Discoverer.new(representation['_links'])

        discoverer.filter.name.wont_be_empty
      end
    end

    describe Discoverer::URLExtractor do
      describe 'url' do
        it 'extracts the url from embedded resources' do
          hal = {'_links' => {'self' => {'href' => '/path/to/resource'}}}
          extractor = Discoverer::URLExtractor.new(hal)

          extractor.url.must_equal '/path/to/resource'
        end

        it 'extracts the url from linked resources' do
          hal = {'href' => '/path/to/resource'}
          extractor = Discoverer::URLExtractor.new(hal)

          extractor.url.must_equal '/path/to/resource'
        end

        it 'deletes the url from linked resources to prevent empty representations' do
          hal = {'href' => '/path/to/resource'}
          Discoverer::URLExtractor.new(hal).url

          hal.include?('href').must_equal false
        end
      end
    end
  end
end
