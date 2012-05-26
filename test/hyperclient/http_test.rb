require_relative '../test_helper'
require 'hyperclient/http'

module Hyperclient
  describe HTTP do
    let (:resource) do
      resource = MiniTest::Mock.new
      resource.expect(:url, 'http://api.example.org/productions/1')
    end

    let (:http) do
      HTTP.new(resource)
    end

    describe 'get' do
      it 'sends a GET request and returns the response body' do
        stub_request(:get, 'api.example.org/productions/1').
          to_return(body: 'This is the resource')

        http.get.must_equal 'This is the resource'
      end
    end

    describe 'post' do
      it 'sends a POST request' do
        stub_request(:post, 'api.example.org/productions/1').
          to_return(body: 'Posting like a big boy huh?', status: 201)

        response = http.post({})
        response.code.must_equal 201
      end
    end

    describe 'put' do
      it 'sends a PUT request' do
        stub_request(:put, 'api.example.org/productions/1').
          to_return(body: 'No changes were made', status: 204)

        response = http.put({})
        response.code.must_equal 204
      end
    end

    describe 'options' do
      it 'sends a OPTIONS request' do
        stub_request(:options, 'api.example.org/productions/1').
          to_return(status: 200, headers: {allow: 'GET, POST'})

        response = http.options
        response.headers.must_include 'allow'
      end
    end

    describe 'head' do
      it 'sends a HEAD request' do
        stub_request(:head, 'api.example.org/productions/1').
          to_return(status: 200, headers: {content_type: 'application/json'})

        response = http.head
        response.headers.must_include 'content-type'
      end
    end

    describe 'delete' do
      it 'sends a DELETE request' do
        stub_request(:delete, 'api.example.org/productions/1').
          to_return(body: 'Resource deleted', status: 200)

        response = http.delete
        response.code.must_equal 200
      end
    end
  end
end