require_relative '../test_helper'
require 'hyperclient/resource'

module Hyperclient
  describe Resource do
    let(:entry_point) { mock('Entry point') }

    describe 'initialize' do
      it 'initializes its links' do
        LinkCollection.expects(:new).with({"self" => { "href" => "/orders/523" }}, entry_point)

        Resource.new({'_links' => {"self" => { "href" => "/orders/523" } }}, entry_point)
      end

      it 'initializes its attributes' do
        Attributes.expects(:new).with({foo: :bar})

        Resource.new({foo: :bar}, entry_point)
      end

      it 'initializes links' do
        ResourceCollection.expects(:new).with({"orders" => []}, entry_point)

        Resource.new({'_embedded' => {"orders" => [] }}, entry_point)
      end

      it "initializes the response" do
        mock_response = mock(body: {})

        resource = Resource.new(mock_response.body, entry_point, mock_response)

        resource.response.must_equal mock_response
      end
    end

    describe 'accessors' do
      let(:resource) do
        Resource.new({}, entry_point)
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

    it 'uses its self Link to handle HTTP connections' do
      self_link = mock('Self Link')
      self_link.expects(:get)

      LinkCollection.expects(:new).returns({'self' => self_link})
      resource = Resource.new({}, entry_point)

      resource.get
    end

    describe ".success?" do
      describe "with a response object" do
        let(:resource) do
          Resource.new({}, entry_point, mock_response)
        end

        let(:mock_response) do
          mock(success?: true)
        end

        it "proxies to the response object" do
          resource.success?.must_equal true
        end
      end

      describe "without a response object" do
        let(:resource) do
          Resource.new({}, entry_point)
        end

        it "returns nil" do
          resource.success?.must_be_nil
        end
      end
    end

    describe ".status" do
      describe "with a response object" do
        let(:resource) do
          Resource.new({}, entry_point, mock_response)
        end

        let(:mock_response) do
          mock(status: 200)
        end

        it "proxies to the response object" do
          resource.status.must_equal 200
        end
      end

      describe "without a response object" do
        let(:resource) do
          Resource.new({}, entry_point)
        end

        it "returns nil" do
          resource.status.must_be_nil
        end
      end
    end
  end
end
