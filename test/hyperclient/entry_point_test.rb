require_relative '../test_helper'
require 'hyperclient/entry_point'

module Hyperclient
  describe EntryPoint do
    let(:api) do
      EntryPoint.new 'http://my.api.org'
    end

    before do
      stub_request(:get, "http://my.api.org/").
          to_return(body: '{"_links": {"self": {"href": "http://my.api.org"}}}', headers: {content_type: 'application/json'})
    end

    describe 'initialize' do
      it 'initializes a Resource at the entry point' do
        api.links['self'].url.must_equal 'http://my.api.org'
      end

      it 'setups the HTTP config' do
        options = {:headers => {'accept-encoding' => 'deflate, gzip'}}

        api = EntryPoint.new('http://my.api.org', options)

        api.config[:headers].must_include 'accept-encoding'
      end

      it 'sets the base_uri for HTTP' do
        api = EntryPoint.new('http://my.api.org')

        api.config[:base_uri].must_equal 'http://my.api.org'
      end
    end

    describe 'method missing' do
      it 'delegates undefined methods to the API when they exist' do
        Resource.any_instance.expects(:foo).returns 'foo'
        api.foo.must_equal 'foo'
      end

      it 'raises an error when the method does not exist in the API' do
        lambda { api.this_method_does_not_exist }.must_raise(NoMethodError)
      end
    end
  end
end