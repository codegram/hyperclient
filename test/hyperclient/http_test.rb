require_relative '../test_helper'
require 'hyperclient/http'

module Hyperclient
  describe HTTP do
    let(:url) do
      '/productions/1'
    end

    let(:http) do
      HTTP.instance_variable_set("@default_options", {})
      HTTP.new(url)
    end

    before do
      Hyperclient.config({})
      Hyperclient.config[:base_uri] = 'http://api.example.org'
    end

    describe 'authentication' do
      it 'sets the authentication options' do
        stub_request(:get, 'http://user:pass@api.example.org/productions/1').
          to_return(body: 'This is the resource')

        Hyperclient.config[:auth] = {type: :basic, credentials: ['user','pass']}

        http.get.must_equal 'This is the resource'
      end
    end

    describe 'headers' do
      it 'sets headers from the given option' do
        Hyperclient.config[:headers] = {'accept-encoding' => 'deflate, gzip'}

        stub_request(:get, 'http://api.example.org/productions/1').
          with(headers: {'Accept-Encoding' => 'deflate, gzip'}).
          to_return(body: 'This is the resource')

        http.get
      end
    end

    describe 'debug' do
      it 'enables debugging' do
        Hyperclient.config[:debug] = true

        http.class.instance_variable_get(:@default_options)[:debug_output].must_equal $stderr
      end

      it 'uses a custom stream' do
        stream = StringIO.new
        Hyperclient.config[:debug] = stream

        http.class.instance_variable_get(:@default_options)[:debug_output].must_equal stream
      end
    end

    describe 'get' do
      it 'sends a GET request and returns the response body' do
        stub_request(:get, 'http://api.example.org/productions/1').
          to_return(body: 'This is the resource')

        http.get.must_equal 'This is the resource'
      end

      it 'returns the parsed response' do
        stub_request(:get, 'http://api.example.org/productions/1').
          to_return(body: '{"some_json": 12345 }', headers: {content_type: 'application/json'})

        http.get.must_equal({'some_json' => 12345})
      end
    end

    describe 'post' do
      it 'sends a POST request' do
        stub_request(:post, 'http://api.example.org/productions/1').
          to_return(body: 'Posting like a big boy huh?', status: 201)

        response = http.post({data: 'foo'})
        response.code.must_equal 201
        assert_requested :post, 'http://api.example.org/productions/1',
                         body: {data: 'foo'}
      end
    end

    describe 'put' do
      it 'sends a PUT request' do
        stub_request(:put, 'http://api.example.org/productions/1').
          to_return(body: 'No changes were made', status: 204)

        response = http.put({attribute: 'changed'})
        response.code.must_equal 204
        assert_requested :put, 'http://api.example.org/productions/1',
                         body: {attribute: 'changed'}
      end
    end

    describe 'options' do
      it 'sends a OPTIONS request' do
        stub_request(:options, 'http://api.example.org/productions/1').
          to_return(status: 200, headers: {allow: 'GET, POST'})

        response = http.options
        response.headers.must_include 'allow'
      end
    end

    describe 'head' do
      it 'sends a HEAD request' do
        stub_request(:head, 'http://api.example.org/productions/1').
          to_return(status: 200, headers: {content_type: 'application/json'})

        response = http.head
        response.headers.must_include 'content-type'
      end
    end

    describe 'delete' do
      it 'sends a DELETE request' do
        stub_request(:delete, 'http://api.example.org/productions/1').
          to_return(body: 'Resource deleted', status: 200)

        response = http.delete
        response.code.must_equal 200
      end
    end
  end
end
