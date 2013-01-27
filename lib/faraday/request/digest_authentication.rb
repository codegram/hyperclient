require 'faraday'
require 'net/http/digest_auth'

module Faraday
  class Request::DigestAuth < Faraday::Middleware
    def initialize(app, user, password)
      super(app)
      @user, @password = user, password
    end

    def call(env)
      response = handshake(env)
      return response unless response.status == 401

      env[:request_headers]['Authorization'] = header(response)
      @app.call(env)
    end

    private
    def handshake(env)
      env_without_body = env.dup
      env_without_body.delete(:body)

      @app.call(env_without_body)
    end

    def header(response)
      uri = response.env[:url]
      uri.user = @user
      uri.password = @password

      realm = response.headers['www-authenticate']
      method = response.env[:method].to_s.upcase

      digest_auth_header(uri, realm, method)
    end

    def digest_auth_header(uri, realm, method)
      digest_auth = Net::HTTP::DigestAuth.new
      digest_auth.auth_header(uri, realm, method)
    end
  end
end

Faraday.register_middleware :request, digest: Faraday::Request::DigestAuth
