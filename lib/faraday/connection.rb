require 'faraday'
require 'faraday/digestauth'

module Faraday
  # Reopen Faraday::Connection to add a helper to set the digest auth data.
  class Connection
    # Public: Adds the digest auth middleware at the top and sets the user and
    # password.
    #
    # user     - A String with the user.
    # password - A String with the password.
    #
    def digest_auth(user, password)
      builder.insert(0, Faraday::Request::DigestAuth, user, password)
    end
  end
end
