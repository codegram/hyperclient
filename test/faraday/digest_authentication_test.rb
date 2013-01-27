require_relative '../test_helper'
require 'faraday/request/digest_authentication'

module Faraday
  describe Request::DigestAuth do
    let(:connection) do
      Faraday.new('http://api.example.org/') do |builder|
        builder.request :digest, 'USER', 'PASS'
        builder.adapter :net_http
      end
    end

    describe 'when the server does not return a 401' do
      it 'does nothing' do
        stub_request(:get, 'http://api.example.org/productions/1').
          to_return(status: 500, body: 'Foo body')

        response = connection.get('/productions/1')
        response.body.must_equal 'Foo body'
      end
    end

    describe 'when the server returns a 401' do
      let(:first_call_headers) { 'Digest realm="MyApp", algorithm=MD5' }
      let(:second_call_headers) { 'Digest username="USER", realm="MyApp", uri="/", algorithm="MD5"' }
      it 'authenticates using digest' do
        stub_request(:get, 'http://api.example.org/productions/1').
          with(body: nil).
          to_return(status: 401, headers: {'www-authenticate' => first_call_headers})

        stub_request(:get, 'http://api.example.org/productions/1').
          with(body: "{\"foo\":1}",
               headers: {'Authorization' => %r{second_call_headers}}).
               to_return(body: '{"resource": "This is the resource"}',
                         headers: {content_type: 'application/json'})

        connection.get('/productions/1')
      end
    end
  end
end
