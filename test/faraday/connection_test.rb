require_relative '../test_helper'
require_relative '../../lib/faraday/connection'

module Faraday
  describe Connection do
    describe 'digest_auth' do
      let(:connection) do
        Faraday.new('http://api.example.org/') do |builder|
          builder.request :url_encoded
          builder.adapter :net_http
        end
      end

      it 'inserts the DigestAuth middleware at the top' do
        connection.digest_auth('user', 'password')

        connection.builder.handlers.first.klass.must_equal Faraday::Request::DigestAuth
      end

      it 'passes the user and password to the middleware' do
        connection.digest_auth('user', 'password')

        Faraday::Request::DigestAuth.expects(:new).with(anything, 'user', 'password').returns(stub_everything)

        connection.get('/')
      end
    end
  end
end
