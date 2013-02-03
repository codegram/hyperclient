require 'json'

module Spinach
  module Fixtures
    def root_response
      '{
          "_links": {
              "self": { "href": "/" },
              "posts": { "href": "/posts" },
              "search": { "href": "/search{?q}", "templated": true },
              "api:authors": { "href": "/authors" }
          }
      }'
    end

    def posts_response
      '{
          "_links": {
            "self": { "href": "/posts" },
            "last_post": {"href": "/posts/1"}
          },
          "total_posts": "9"
      }'
    end

    def post_response
      '{
          "_links": {
            "self": { "href": "/posts/1" }
          },
          "title": "My first blog post",
          "body":  "Lorem ipsum dolor sit amet",
          "_embedded": {
            "comments": [
              {
                "title": "Some comment"
              } 
            ]
          }
      }'
    end
  end
end
