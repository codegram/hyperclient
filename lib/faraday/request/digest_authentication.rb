require 'faraday'
require 'net/http/digest_auth'

module Faraday
  # Public: A Faraday middleware to use digest authentication. Since order of
  # middlewares do care, it should be the first one of the Request middlewares
  # in order to work properly (due to how digest authentication works).
  #
  # If some requests using the connection don't need to use digest auth you
  # don't have to worry, the middleware will do nothing.
  #
  # It uses Net::HTTP::DigestAuth to generate the authorization header but it
  # should work with any adapter.
  #
  # Examples:
  #
  #   connection = Faraday.new(...) do |connection|
  #     connection.request :digest, USER, PASSWORD
  #   end
  #
  #   # You can also use it later with a connection:
  #   connection.digest_auth('USER', 'PASSWORD')
  #
  class Request::DigestAuth < Faraday::Middleware

    # Public: Initializes a DigestAuth.
    #
    # app      - The Faraday app.
    # user     - A String with the user to authentication the connection.
    # password - A String with the password to authentication the connection.
    def initialize(app, user, password)
      super(app)
      @user, @password = user, password
    end

    # Public: Sends a first request with an empty body to get the
    # authentication headers and then send the same request with the body and
    # authorization header.
    #
    # env - A Hash with the request environment.
    #
    # Returns a Faraday::Response.
    def call(env)
      response = handshake(env)
      return response unless response.status == 401

      env[:request_headers]['Authorization'] = header(response)
      @app.call(env)
    end

    private
    # Internal: Sends the the request with an empry body.
    #
    # env - A Hash with the request environment.
    #
    # Returns a Faraday::Response.
    def handshake(env)
      env_without_body = env.dup
      env_without_body.delete(:body)

      @app.call(env_without_body)
    end

    # Internal: Builds the authorization header with the authentication data.
    #
    # response - A Faraday::Response with the authenticate headers.
    #
    # Returns a String with the DigestAuth header.
    def header(response)
      uri = response.env[:url]
      uri.user = @user
      uri.password = @password

      realm = response.headers['www-authenticate']
      method = response.env[:method].to_s.upcase

      Net::HTTP::DigestAuth.new.auth_header(uri, realm, method)
    end
  end
end

# Register the middleware as a Request middleware with the name :digest
registry = [Faraday, Faraday::Middleware].find{|mod| mod.respond_to?(:register_middleware)}
raise "Could not find method register_middleware on Faraday or Faraday::Middleware" unless registry
registry.register_middleware :request, digest: Faraday::Request::DigestAuth
