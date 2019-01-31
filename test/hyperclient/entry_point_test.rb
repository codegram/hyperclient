require_relative '../test_helper'
require 'hyperclient'

module Hyperclient
  describe EntryPoint do
    describe 'default' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org'
      end

      describe 'connection' do
        it 'creates a Faraday connection with the entry point url' do
          entry_point.connection.url_prefix.to_s.must_equal 'http://my.api.org/'
        end

        it 'creates a Faraday connection with the default headers' do
          entry_point.headers['Content-Type'].must_equal 'application/hal+json'
          entry_point.headers['Accept'].must_equal 'application/hal+json,application/json'
        end

        it 'can update headers after a connection has been constructed' do
          entry_point.connection.must_be_kind_of Faraday::Connection
          entry_point.headers.update('Content-Type' => 'application/foobar')
          entry_point.headers['Content-Type'].must_equal 'application/foobar'
        end

        it 'can insert additional middleware after a connection has been constructed' do
          entry_point.connection.must_be_kind_of Faraday::Connection
          entry_point.connection.use :instrumentation
          handlers = entry_point.connection.builder.handlers
          handlers.must_include FaradayMiddleware::Instrumentation
        end

        it 'creates a Faraday connection with the default block' do
          handlers = entry_point.connection.builder.handlers

          handlers.must_include Faraday::Response::RaiseError
          handlers.must_include FaradayMiddleware::FollowRedirects
          handlers.must_include FaradayMiddleware::EncodeHalJson
          handlers.must_include FaradayMiddleware::ParseHalJson
          handlers.must_include Faraday::Adapter::NetHttp

          entry_point.connection.options.params_encoder.must_equal Faraday::FlatParamsEncoder
        end

        it 'raises a  ConnectionAlreadyInitializedError if attempting to modify headers' do
          entry_point.connection.must_be_kind_of Faraday::Connection
          -> { entry_point.headers = {} }.must_raise ConnectionAlreadyInitializedError
        end

        it 'raises a  ConnectionAlreadyInitializedError if attempting to modify the faraday block' do
          entry_point.connection.must_be_kind_of Faraday::Connection
          -> { entry_point.connection {} }.must_raise ConnectionAlreadyInitializedError
        end
      end

      describe 'initialize' do
        it 'sets a Link with the entry point url' do
          entry_point._url.must_equal 'http://my.api.org'
        end
      end
    end

    describe 'faraday_options' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org' do |entry_point|
          entry_point.faraday_options = { proxy: 'http://my.proxy:8080' }
        end
      end

      describe 'connection' do
        it 'creates a Faraday connection with the entry point url' do
          entry_point.connection.url_prefix.to_s.must_equal 'http://my.api.org/'
        end

        it 'creates a Faraday connection with the default headers' do
          entry_point.headers['Content-Type'].must_equal 'application/hal+json'
          entry_point.headers['Accept'].must_equal 'application/hal+json,application/json'
        end

        it 'creates a Faraday connection with options' do
          entry_point.connection.proxy.must_be_kind_of Faraday::ProxyOptions
          entry_point.connection.proxy.uri.to_s.must_equal 'http://my.proxy:8080'
        end
      end
    end

    describe 'options' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org' do |entry_point|
          entry_point.connection(proxy: 'http://my.proxy:8080')
        end
      end

      describe 'connection' do
        it 'creates a Faraday connection with the entry point url' do
          entry_point.connection.url_prefix.to_s.must_equal 'http://my.api.org/'
        end

        it 'creates a Faraday connection with the default headers' do
          entry_point.headers['Content-Type'].must_equal 'application/hal+json'
          entry_point.headers['Accept'].must_equal 'application/hal+json,application/json'
        end

        it 'creates a Faraday connection with options' do
          entry_point.connection.proxy.must_be_kind_of Faraday::ProxyOptions
          entry_point.connection.proxy.uri.to_s.must_equal 'http://my.proxy:8080'
        end
      end
    end

    describe 'custom' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org' do |entry_point|
          entry_point.connection(default: false) do |conn|
            conn.request :json
            conn.response :json, content_type: /\bjson$/
            conn.adapter :net_http
          end

          entry_point.headers = {
            'Content-Type' => 'application/foobar',
            'Accept' => 'application/foobar'
          }
        end
      end

      describe 'connection' do
        it 'creates a Faraday connection with the entry point url' do
          entry_point.connection.url_prefix.to_s.must_equal 'http://my.api.org/'
        end

        it 'creates a Faraday connection with non-default headers' do
          entry_point.headers['Content-Type'].must_equal 'application/foobar'
          entry_point.headers['Accept'].must_equal 'application/foobar'
        end

        it 'creates a Faraday connection with the default block' do
          handlers = entry_point.connection.builder.handlers
          handlers.wont_include Faraday::Response::RaiseError
          handlers.wont_include FaradayMiddleware::FollowRedirects
          handlers.must_include FaradayMiddleware::EncodeJson
          handlers.must_include FaradayMiddleware::ParseJson
          handlers.must_include Faraday::Adapter::NetHttp
        end
      end
    end

    describe 'inherited' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org' do |entry_point|
          entry_point.connection do |conn|
            conn.use Faraday::Request::OAuth
          end
          entry_point.headers['Access-Token'] = 'token'
        end
      end

      describe 'connection' do
        it 'creates a Faraday connection with the default and additional headers' do
          entry_point.headers['Content-Type'].must_equal 'application/hal+json'
          entry_point.headers['Accept'].must_equal 'application/hal+json,application/json'
          entry_point.headers['Access-Token'].must_equal 'token'
        end

        it 'creates a Faraday connection with the entry point url' do
          entry_point.connection.url_prefix.to_s.must_equal 'http://my.api.org/'
        end

        it 'creates a Faraday connection with the default block plus any additional handlers' do
          handlers = entry_point.connection.builder.handlers

          handlers.must_include Faraday::Request::OAuth
          handlers.must_include Faraday::Response::RaiseError
          handlers.must_include FaradayMiddleware::FollowRedirects
          handlers.must_include FaradayMiddleware::EncodeHalJson
          handlers.must_include FaradayMiddleware::ParseHalJson
          handlers.must_include Faraday::Adapter::NetHttp

          entry_point.connection.options.params_encoder.must_equal Faraday::FlatParamsEncoder
        end
      end
    end
  end
end
