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
            conn.use Faraday::Request::Instrumentation
          end
          client.headers['Access-Token'] = 'token'
        end
      end

      it 'creates a Faraday connection with the default and additional headers' do
        _(client.headers['Content-Type']).must_equal 'application/hal+json'
        _(client.headers['Accept']).must_equal 'application/hal+json,application/json'
        _(client.headers['Access-Token']).must_equal 'token'
      end

      it 'creates a Faraday connection with the entry point url' do
        _(client.connection.url_prefix.to_s).must_equal 'http://api.example.org/'
      end

      it 'creates a Faraday connection with the default block plus any additional handlers' do
        handlers = client.connection.builder.handlers
        _(handlers).must_include Faraday::Request::Instrumentation
        _(handlers).must_include Faraday::Response::RaiseError
        _(handlers).must_include Faraday::FollowRedirects::Middleware
        _(handlers).must_include Faraday::HalJson::Request
        _(handlers).must_include Faraday::HalJson::Response
      end
    end
  end
end
