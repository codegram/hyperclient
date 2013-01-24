require_relative '../test_helper'
require 'hyperclient/http'

module Hyperclient
  describe HTTP do
    let(:url) do
      '/productions/1'
    end

    let(:config) { {base_uri: 'http://api.example.org'} }

    let(:http) do
      HTTP.new(url, config)
    end

    describe 'initialize' do
      it 'warns when invalid options given' do
        proc do
          HTTP.new(url, nil)
        end.must_raise RuntimeError
      end

      it 'sets the default headers' do
        http.headers.wont_be_nil
      end

      it 'sets authentication options' do
        auth_config = config.merge({auth: {type: :basic, user: 'foo', password: 'baz'}})

        http = HTTP.new(url, auth_config)
        http.connection.headers['Authorization'].wont_be_empty
      end
    end

    describe 'url' do
      it 'merges the resource url with the base uri' do
        http.url.to_s.must_equal 'http://api.example.org/productions/1'
      end

      it 'returns the given url if it cannot merge it' do
        config = {base_uri: nil}
        http = HTTP.new(url, config)
        http.url.to_s.must_equal '/productions/1'
      end
    end

    describe 'basic_auth' do
      it 'sets the basic authentication options' do
        stub_request(:get, 'http://user:pass@api.example.org/productions/1').
          to_return(body: '{"resource": "This is the resource"}',
           headers: {content_type: 'application/json'})

        http.basic_auth('user', 'pass')
        http.get.body.must_equal({'resource' => 'This is the resource'})
      end
    end

    describe 'digest_auth' do
      it 'sets the digest authentication options' do
        stub_request(:post, 'http://api.example.org/productions/1').
          with(body: nil).
          to_return(status: 401, headers: {'www-authenticate' => 'private area'})

        stub_request(:post, 'http://api.example.org/productions/1').
          with(body: "{\"foo\":1}",
               headers: {'Authorization' =>
            %r{Digest username="user", realm="", algorithm=MD5, uri="/productions/1"}}).
          to_return(body: '{"resource": "This is the resource"}',
           headers: {content_type: 'application/json'})

        http.digest_auth('user', 'pass')
        http.post({foo: 1}).body.must_equal({'resource' => 'This is the resource'})
      end
    end

    describe 'headers' do
      it 'sets headers from the given option' do

        stub_request(:get, 'http://api.example.org/productions/1').
          with(headers: {'Accept-Encoding' => 'deflate, gzip'}).
          to_return(body: '{"resource": "This is the resource"}')

        http.headers = {'accept-encoding' => 'deflate, gzip'}
        http.get
      end
    end

    describe 'log!' do
      before(:each) do
        stub_request(:get, 'http://api.example.org/productions/1').
          to_return(body: '{"resource": "This is the resource"}')
      end

      it 'adds a logger to the connection' do
        output = StringIO.new
        logger = Logger.new(output)

        http.log!(logger)
        http.get

        output.string.must_include('get http://api.example.org/productions/1')
      end
    end

    describe 'faraday' do
      describe 'faraday_options' do
        it 'merges with the default options'
      end

      describe 'faraday_block' do
        it 'uses the given faraday block'
        it 'fallbacks to the default block'

        describe 'default block' do
          it 'parses JSON' do
            stub_request(:get, 'http://api.example.org/productions/1').
              to_return(body: '{"some_json": 12345 }', headers: {content_type: 'application/json'})

            response = http.get
            response.body.must_equal({'some_json' => 12345})
          end

          it 'encodes JSON'
          it 'uses Net::HTTP'
        end
      end
    end

    describe 'get' do
      it 'sends a GET request' do
        stub_request(:get, 'http://api.example.org/productions/1')

        http.get
        assert_requested :get, 'http://api.example.org/productions/1'
      end
    end

    describe 'post' do
      it 'sends a POST request' do
        stub_request(:post, 'http://api.example.org/productions/1').
          to_return(body: 'Posting like a big boy huh?', status: 201)

        response = http.post({data: 'foo'})
        response.status.must_equal 201
        assert_requested :post, 'http://api.example.org/productions/1',
                         body: {data: 'foo'}
      end
    end

    describe 'put' do
      it 'sends a PUT request' do
        stub_request(:put, 'http://api.example.org/productions/1').
          to_return(body: 'No changes were made', status: 204)

        response = http.put({attribute: 'changed'})
        response.status.must_equal 204
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
        response.status.must_equal 200
      end
    end
  end
end
