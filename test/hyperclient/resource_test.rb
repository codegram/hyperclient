require_relative '../test_helper'
require 'hyperclient/resource'

module Hyperclient
  describe Resource do
    let(:representation) do
      JSON.parse( File.read('test/fixtures/element.json'))
    end

    describe 'initialize' do
      it 'initializes its links' do
        LinkCollection.expects(:new).with(representation)

        Resource.new(representation)
      end

      it 'initializes its attributes' do
        Attributes.expects(:new).with(representation)

        Resource.new(representation)
      end

      it 'initializes links' do
        ResourceCollection.expects(:new).with(representation)

        Resource.new(representation)
      end
    end

    describe 'accessors' do
      let(:resource) do
        Resource.new(representation)
      end

      describe 'links' do
        it 'returns a LinkCollection' do
          resource.links.must_be_kind_of LinkCollection
        end
      end

      describe 'attributes' do
        it 'returns a Attributes' do
          resource.attributes.must_be_kind_of Attributes
        end
      end

      describe 'embedded' do
        it 'returns a ResourceCollection' do
          resource.embedded.must_be_kind_of ResourceCollection
        end
      end
    end

    describe 'reload' do
    end
  end
end
