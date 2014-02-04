require_relative '../test_helper'
require 'hyperclient/entry_point'

module Hyperclient
  describe EntryPoint do
    let(:entry_point) do
      EntryPoint.new 'http://my.api.org'
    end

    describe 'connection' do
      it 'creates a Faraday connection with the entry point url' do
        entry_point.connection.url_prefix.to_s.must_equal 'http://my.api.org/'
      end

      it 'creates a Faraday connection with the default headers' do
        entry_point.headers['Content-Type'].must_equal 'application/json'
        entry_point.headers['Accept'].must_equal 'application/json'
      end

      it 'creates a Faraday connection with the default block' do
        handlers = entry_point.connection.builder.handlers
        handlers.must_include FaradayMiddleware::EncodeJson
        handlers.must_include FaradayMiddleware::ParseJson
        handlers.must_include Faraday::Adapter::NetHttp
      end

      describe 'when initialized with a custom block' do
        let(:entry_point) do
          EntryPoint.new('http://my.api.org') do |connection|
            connection.use FaradayMiddleware::FollowRedirects
            connection.adapter :net_http
          end
        end

        it 'creates a Faraday connection with that block' do
          handlers = entry_point.connection.builder.handlers
          handlers.must_include Faraday::Adapter::NetHttp
          handlers.must_include FaradayMiddleware::FollowRedirects
        end
      end
    end

    describe 'initialize' do
      it 'sets a Link with the entry point url' do
        entry_point.url.must_equal 'http://my.api.org'
      end
    end
  end
end