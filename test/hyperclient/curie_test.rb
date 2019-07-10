# typed: false
require_relative '../test_helper'
require 'hyperclient'

module Hyperclient
  describe Curie do
    let(:entry_point) do
      EntryPoint.new('http://api.example.org/')
    end

    describe 'templated?' do
      it 'returns true if the curie is templated' do
        curie = Curie.new({ 'name' => 'image', 'templated' => true }, entry_point)

        curie.templated?.must_equal true
      end

      it 'returns false if the curie is not templated' do
        curie = Curie.new({ 'name' => 'image' }, entry_point)

        curie.templated?.must_equal false
      end
    end

    let(:curie) do
      Curie.new({ 'name' => 'image', 'href' => '/images/{rel}', 'templated' => true }, entry_point)
    end
    describe '_name' do
      it 'returns curie name' do
        curie.name.must_equal 'image'
      end
    end
    describe 'expand' do
      it 'expands link' do
        curie.expand('thumbnail').must_equal '/images/thumbnail'
      end
    end
  end
end
