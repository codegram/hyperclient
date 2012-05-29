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

      it 'returns the given url if it cannot merge it' do
        resource = Resource.new('/search={terms}')
        resource.url.to_s.must_equal '/search={terms}'
      end
    end

    describe 'initialize' do
      before do
        stub_request(:get, 'http://api.example.org')
      end

      it 'initializes the response when one is given' do
        resource = Resource.new('/', {response: JSON.parse(response)})

        assert_not_requested(:get, 'http://api.example.org/')
      end

      it 'updates the resource URL if the response has one' do
        resource = Resource.new('/', {response: JSON.parse(response)})

        resource.url.must_include '/productions/1'
      end

      it 'does no update the resource URL if the response does not have one' do
        resource = Resource.new('/', {})

        resource.url.wont_include '/productions/1'
      end

      it 'sets the resource name' do
        resource = Resource.new('/', {name: 'posts'})

        resource.name.must_equal 'posts'
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

      it 'returns itself' do
        resource = Resource.new('/productions/1')

        resource.reload.must_equal resource
      end
    end
  end
end
