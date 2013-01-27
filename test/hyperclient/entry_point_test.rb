require_relative '../test_helper'
require 'hyperclient/entry_point'

module Hyperclient
  describe EntryPoint do
    let(:entry_point) do
      EntryPoint.new 'http://my.api.org'
    end

    before do
      stub_request(:get, "http://my.api.org/").
          to_return(body: '{"_links": {"self": {"href": "http://my.api.org"}}}', headers: {content_type: 'application/json'})
    end

    describe 'connection' do
      it 'creates a Faraday connection with the entry point url'
      it 'creates a Faraday connection with the default headers'
      it 'creates a Faraday connection with the default block'
    end

    describe 'entry' do
      it 'creates a Link with the entry point url'
      it 'returns the entry point Resource'
    end

    describe 'method missing' do
      it 'delegates undefined methods to the API when they exist' do
        Resource.any_instance.expects(:foo).returns 'foo'
        entry_point.foo.must_equal 'foo'
      end

      it 'responds to missing methods' do
        Resource.any_instance.expects(:respond_to?).with('foo').returns(true)
        entry_point.respond_to?(:foo).must_equal true
      end

      it 'raises an error when the method does not exist in the API' do
        lambda { entry_point.this_method_does_not_exist }.must_raise(NoMethodError)
      end
    end
  end
end