require_relative '../test_helper'
require 'hyperclient/attributes'

module Hyperclient
  describe Attributes do
    let(:representation) do
      JSON.parse( File.read('test/fixtures/element.json'))
    end

    let(:attributes) do
      Attributes.new(representation)
    end

    it 'does not set _links as an attribute' do
      attributes.wont_respond_to :_links
    end

    it 'does not set _embedded as an attribute' do
      attributes.wont_respond_to :_embedded
    end

    it 'is a collection' do
      Attributes.ancestors.must_include Collection
    end
  end
end
