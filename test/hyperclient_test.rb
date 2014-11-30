require 'test_helper'
require 'hyperclient'

describe Hyperclient do
  describe 'new' do
    it 'creates a new EntryPoint with the url' do
      Hyperclient::EntryPoint.expects(:new).with('http://api.example.org')

      Hyperclient.new('http://api.example.org')
    end

    describe 'with an optional block' do
      let(:client) do
        Hyperclient.new('http://api.example.org') do |client|
          client.connection(default: true) do |conn|
            conn.use Faraday::Request::OAuth
          end
          client.headers['Access-Token'] = 'token'
        end
      end

      it 'creates a Faraday connection with the default and additional headers' do
        client.headers['Content-Type'].must_equal 'application/hal+json'
        client.headers['Accept'].must_equal 'application/hal+json,application/json'
        client.headers['Access-Token'].must_equal 'token'
      end

      it 'creates a Faraday connection with the entry point url' do
        client.connection.url_prefix.to_s.must_equal 'http://api.example.org/'
      end

      it 'creates a Faraday connection with the default block plus any additional handlers' do
        handlers = client.connection.builder.handlers
        handlers.must_include Faraday::Request::OAuth
        handlers.must_include Faraday::Response::RaiseError
        handlers.must_include FaradayMiddleware::FollowRedirects
        handlers.must_include FaradayMiddleware::EncodeHalJson
        handlers.must_include FaradayMiddleware::ParseHalJson
        handlers.must_include Faraday::Adapter::NetHttp
      end
    end
  end
end
