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

    describe 'initialize' do
      it 'setups the HTTP config' do
        options = {:headers => {'accept-encoding' => 'deflate, gzip'}}

        entry_point = EntryPoint.new('http://my.api.org', options)

        entry_point.config[:headers].must_include 'accept-encoding'
      end

      it 'sets the base_uri for HTTP' do
        entry_point = EntryPoint.new('http://my.api.org')

        entry_point.config[:base_uri].must_equal 'http://my.api.org'
      end
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