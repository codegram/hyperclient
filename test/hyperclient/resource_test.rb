require_relative '../test_helper'
require 'hyperclient'

module Hyperclient
  describe Resource do
    let(:entry_point) { mock('Entry point') }

    describe 'initialize' do
      it 'initializes its links' do
        LinkCollection.expects(:new).with({ 'self' => { 'href' => '/orders/523' } }, nil, entry_point)

        Resource.new({ '_links' => { 'self' => { 'href' => '/orders/523' } } }, entry_point)
      end

      it 'initializes its attributes' do
        Attributes.expects(:new).with(foo: :bar)

        Resource.new({ foo: :bar }, entry_point)
      end

      it 'initializes links' do
        ResourceCollection.expects(:new).with({ 'orders' => [] }, entry_point)

        Resource.new({ '_embedded' => { 'orders' => [] } }, entry_point)
      end

      it 'initializes the response' do
        mock_response = mock(body: {})

        resource = Resource.new(mock_response.body, entry_point, mock_response)

        resource._response.must_equal mock_response
      end

      it 'does not mutate the response.body' do
        body = { 'foo' => 'bar', '_links' => {}, '_embedded' => {} }
        mock_response = stub(body: body.dup)

        resource = Resource.new(mock_response.body, entry_point, mock_response)

        resource._response.body.must_equal body
      end

      describe 'with an empty body in response' do
        it 'initializes the response' do
          mock_response = mock(body: '')

          resource = Resource.new(mock_response.body, entry_point, mock_response)

          resource._response.must_equal mock_response
        end
      end

      describe 'with an invalid representation' do
        it 'raises an InvalidRepresentationError' do
          proc { Resource.new('invalid representation data', entry_point) }.must_raise InvalidRepresentationError
        end
      end
    end

    describe '_links' do
      it '_expand' do
        resource = Resource.new({ '_links' => { 'orders' => { 'href' => '/orders/{id}', 'templated' => true } } }, entry_point)
        resource._links.orders._expand(id: 1)._url.must_equal '/orders/1'
        resource.orders._expand(id: 1)._url.must_equal '/orders/1'
        resource.orders(id: 1)._url.must_equal '/orders/1'
      end
    end

    describe 'accessors' do
      let(:resource) do
        Resource.new({}, entry_point)
      end

      describe 'links' do
        it 'returns a LinkCollection' do
          resource._links.must_be_kind_of LinkCollection
        end
      end

      describe 'attributes' do
        it 'returns a Attributes' do
          resource._attributes.must_be_kind_of Attributes
        end
      end

      describe 'embedded' do
        it 'returns a ResourceCollection' do
          resource._embedded.must_be_kind_of ResourceCollection
        end
      end

      describe 'method_missing' do
        it 'delegates to attributes' do
          resource._attributes.expects(:foo).returns('bar')
          resource.foo.must_equal 'bar'
        end

        it 'delegates to links' do
          resource._links.expects(:foo).returns('bar')
          resource.foo.must_equal 'bar'
        end

        it 'delegates to embedded' do
          resource._embedded.expects(:foo).returns('bar')
          resource.foo.must_equal 'bar'
        end

        it 'delegates to attributes, links, embedded' do
          resource._attributes.expects('respond_to?').with('foo').returns(false)
          resource._links.expects('respond_to?').with('foo').returns(false)
          resource._embedded.expects('respond_to?').with('foo').returns(false)
          -> { resource.foo }.must_raise NoMethodError
        end

        it 'delegates []' do
          resource._attributes.expects(:foo).returns('bar')
          resource['foo'].must_equal 'bar'
        end

        describe '#fetch' do
          it 'returns the value for keys that exist' do
            resource._attributes.expects(:foo).returns('bar')

            resource.fetch('foo').must_equal 'bar'
          end

          it 'raises an error for missing keys' do
            proc { resource.fetch('missing key') }.must_raise KeyError
          end

          describe 'with a default value' do
            it 'returns the value for keys that exist' do
              resource._attributes.expects(:foo).returns('bar')
              resource.fetch('foo', 'default value').must_equal 'bar'
            end

            it 'returns the default value for missing keys' do
              resource.fetch('missing key', 'default value').must_equal 'default value'
            end
          end

          describe 'with a block' do
            it 'returns the value for keys that exist' do
              resource._attributes.expects(:foo).returns('bar')
              resource.fetch('foo') { 'default value' }.must_equal 'bar'
            end

            it 'returns the value from the block' do
              resource.fetch('z') { 'go fish!' }.must_equal 'go fish!'
            end

            it 'returns the value with args from the block' do
              resource.fetch('z') { |el| "go fish, #{el}" }.must_equal 'go fish, z'
            end
          end
        end
      end
    end

    it 'uses its self Link to handle HTTP connections' do
      self_link = mock('Self Link')
      self_link.expects(:_get)

      LinkCollection.expects(:new).returns('self' => self_link)
      resource = Resource.new({}, entry_point)

      resource._get
    end

    describe '._success?' do
      describe 'with a response object' do
        let(:resource) do
          Resource.new({}, entry_point, mock_response)
        end

        let(:mock_response) do
          mock(success?: true)
        end

        it 'proxies to the response object' do
          resource._success?.must_equal true
        end
      end

      describe 'without a response object' do
        let(:resource) do
          Resource.new({}, entry_point)
        end

        it 'returns nil' do
          resource._success?.must_be_nil
        end
      end
    end

    describe '._status' do
      describe 'with a response object' do
        let(:resource) do
          Resource.new({}, entry_point, mock_response)
        end

        let(:mock_response) do
          mock(status: 200)
        end

        it 'proxies to the response object' do
          resource._status.must_equal 200
        end
      end

      describe 'without a response object' do
        let(:resource) do
          Resource.new({}, entry_point)
        end

        it 'returns nil' do
          resource._status.must_be_nil
        end
      end
    end
  end
end
