require_relative '../test_helper'
require 'hyperclient/resource'

module Hyperclient
  describe Resource do
    describe 'initialize' do
      it 'initializes its links' do
        LinkCollection.expects(:new).with({"self" => { "href" => "/orders/523" }})

        Resource.new({'_links' => {"self" => { "href" => "/orders/523" } }})
      end

      it 'initializes its attributes' do
        Attributes.expects(:new).with({foo: :bar})

        Resource.new({foo: :bar})
      end

      it 'initializes links' do
        ResourceCollection.expects(:new).with({"orders" => []})

        Resource.new({'_embedded' => {"orders" => [] }})
      end
    end

    describe 'accessors' do
      let(:resource) do
        Resource.new({})
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
