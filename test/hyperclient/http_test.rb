require_relative '../test_helper'
require 'pry'
require 'hyperclient/http'

module Hyperclient
  describe HTTP do
    let (:resource) do
      resource = MiniTest::Mock.new
      resource.expect(:url, 'http://api.example.org/productions/1')
    end

    let (:http) do
      HTTP.instance_variable_set("@default_options", {})
      HTTP.new(resource)
    end

    describe 'authentication' do
      it 'sets the authentication options' do
        stub_request(:get, 'user:pass@api.example.org/productions/1').
          to_return(body: 'This is the resource')

        http = HTTP.new(resource, {auth: {type: :basic, credentials: ['user','pass']}})
        http.get.must_equal 'This is the resource'
      end
    end

    describe 'headers' do
      it 'sets headers from the given option' do
        http = HTTP.new(resource, {headers: {'accept-encoding' => 'deflate, gzip'}})

        stub_request(:get, 'api.example.org/productions/1').
          with(headers: {'Accept-Encoding' => 'deflate, gzip'}).
          to_return(body: 'This is the resource')

        http.get
      end
    end

    describe 'debug' do
      it 'enables debugging' do
        http = HTTP.new(resource, {debug: true})

        http.class.instance_variable_get(:@default_options)[:debug_output].must_equal $stderr
      end

      it 'uses a custom stream' do
        stream = StringIO.new
        http = HTTP.new(resource, {debug: stream})

        http.class.instance_variable_get(:@default_options)[:debug_output].must_equal stream
      end
    end

    describe 'get' do
      it 'sends a GET request and returns the response body' do
        stub_request(:get, 'api.example.org/productions/1').
          to_return(body: 'This is the resource')

        http.get.must_equal 'This is the resource'
      end

      it 'returns the parsed response' do
        stub_request(:get, 'api.example.org/productions/1').
          to_return(body: '{"some_json": 12345 }', headers: {content_type: 'application/json'})

        http.get.must_equal({'some_json' => 12345})
      end
    end

    describe 'post' do
      it 'sends a POST request' do
        stub_request(:post, 'api.example.org/productions/1').
          to_return(body: 'Posting like a big boy huh?', status: 201)

        response = http.post({data: 'foo'})
        response.code.must_equal 201
        assert_requested :post, 'http://api.example.org/productions/1',
                         body: {data: 'foo'}
      end
    end

    describe 'put' do
      it 'sends a PUT request' do
        stub_request(:put, 'api.example.org/productions/1').
          to_return(body: 'No changes were made', status: 204)

        response = http.put({attribute: 'changed'})
        response.code.must_equal 204
        assert_requested :put, 'http://api.example.org/productions/1',
                         body: {attribute: 'changed'}
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
