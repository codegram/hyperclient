require_relative '../test_helper'
require 'hyperclient/resource'

module Hyperclient
  describe Resource do
    let(:response) do
      File.read('test/fixtures/element.json')
    end

    let(:parsed_response) do
      JSON.parse(response)
    end

    before do
      Resource.entry_point = 'http://api.example.org'
    end

    describe 'url' do
      it 'merges the resource url with the entry point' do
        resource = Resource.new('/path/to/resource')
        resource.url.to_s.must_equal 'http://api.example.org/path/to/resource'
      end
    end

    describe 'method_missing' do
      let(:resource) do
        Resource.new('/', parsed_response)
      end

      it 'defines a method when the method is a resource' do
        resource.filter.must_be_kind_of Resource
      end

      it 'raises when there is no resource with that method name' do
        lambda {
          resource.fake_resource
        }.must_raise NoMethodError
      end
    end

    describe 'initialize' do
      it 'initializes the response when one is given' do
        resource = Resource.new('/', parsed_response)

        resource.attributes.wont_be_empty
      end
    end

    describe 'reload' do
      before do
        stub_request(:get, "http://api.example.org/productions/1").
          to_return(:status => 200, :body => response, headers: {content_type: 'application/json'})
      end

      it 'retrives itself from the API' do
        resource = Resource.new('/productions/1')
        resource.reload

        assert_requested(:get, 'http://api.example.org/productions/1', times: 1)
      end
    end
  end
end
