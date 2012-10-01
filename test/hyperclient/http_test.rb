require_relative '../test_helper'
require 'hyperclient/http'

module Hyperclient
  describe HTTP do
    let(:url) do
      '/productions/1'
    end

    let(:config) { {base_uri: 'http://api.example.org'} }

    let(:http) do
      HTTP.instance_variable_set("@default_options", {})
      HTTP.new(url, config)
    end

    describe 'initialize' do
      it 'passes options to faraday' do
        Faraday.expects(:new).with(:headers => {}, :url => config[:base_uri],
          :x => :y).returns(stub('faraday', :get => stub(:body => '{}')))

        HTTP.new(url, config.merge(:faraday_options => {:x => :y})).get
      end

      it 'passes the options to faraday again when initializing it again' do
        Faraday.expects(:new).with(:headers => {}, :url => config[:base_uri],
          :x => :y).returns(stub('faraday', :get => stub(:body => '{}'))).times(2)

        full_config = config.merge(:faraday_options => {:x => :y})
        2.times { HTTP.new(url, full_config).get }
      end

      it 'passes a block to faraday' do
        app = stub('app')
        http = HTTP.new(url, config.merge(
          :faraday_options => {:block => lambda{|f| f.adapter :rack, app}}))

        app.expects(:call).returns([200, {}, '{}'] )

        http.get
      end

      it 'passes a block to faraday again when initializing again' do
        app = stub('app')

        app.expects(:call).returns([200, {}, '{}'] ).times(2)

        full_config = config.merge(:faraday_options => {:block => lambda{|f|
          f.adapter :rack, app}})
        2.times {
          http = HTTP.new(url, full_config)
          http.get
        }
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

    describe 'authentication' do
      it 'sets the authentication options' do
        stub_request(:get, 'http://user:pass@api.example.org/productions/1').
          to_return(body: '{"resource": "This is the resource"}')

        config.update({auth: {type: :basic, user: 'user', password: 'pass'}})

        http.get.must_equal({'resource' => 'This is the resource'})
      end
    end

    describe 'headers' do
      it 'sets headers from the given option' do
        config.update({headers: {'accept-encoding' => 'deflate, gzip'}})

        stub_request(:get, 'http://api.example.org/productions/1').
          with(headers: {'Accept-Encoding' => 'deflate, gzip'}).
          to_return(body: '{"resource": "This is the resource"}')

        http.get
      end
    end

    describe 'debug' do
      before(:each) do
        @stderr = $stderr
        stub_request(:get, 'http://api.example.org/productions/1').
          to_return(body: '{"resource": "This is the resource"}')
      end

      after(:each) do
        $stderr = @stderr
      end

      it 'enables debugging' do
        $stderr = StringIO.new
        config.update({debug: true})

        http.get

        $stderr.string.must_include('get http://api.example.org/productions/1')
      end

      it 'uses a custom stream' do
        stream = StringIO.new
        config.update({debug: stream})

        http.get

        stream.string.must_include('get http://api.example.org/productions/1')
      end
    end

    describe 'get' do
      it 'sends a GET request and returns the response body' do
        stub_request(:get, 'http://api.example.org/productions/1').
          to_return(body: '{"resource": "This is the resource"}')

        http.get.must_equal({'resource' => 'This is the resource'})
      end

      it 'returns the parsed response' do
        stub_request(:get, 'http://api.example.org/productions/1').
          to_return(body: '{"some_json": 12345 }', headers: {content_type: 'application/json'})

        http.get.must_equal({'some_json' => 12345})
      end

      it 'returns nil if the response body is nil' do
        stub_request(:get, 'http://api.example.org/productions/1').
          to_return(body: nil)

        http.get.must_equal(nil)
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
