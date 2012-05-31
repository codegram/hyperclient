require_relative '../test_helper'
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
  end
end
