require 'faraday'
require_relative 'request/digest_authentication'

module Faraday
  class Connection
    def digest_auth(user, password)
      self.builder.insert(0, Faraday::Request::DigestAuth, user, password)
    end
  end
end
