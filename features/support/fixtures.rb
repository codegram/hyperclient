require 'json'

module Spinach
  module Fixtures
    def root_response
      '{
          "_links": {
              "self": { "href": "/" },
              "posts": { "href": "/posts" },
              "search": { "href": "/search{?q}", "templated": true },
              "api:authors": { "href": "/authors" },
              "next": { "href": "/page2" }
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

    def page2_response
      '{
          "_links": {
              "self": { "href": "/page2" },
              "posts": { "href": "/posts_of_page2" },
              "next": { "href": "/page3" }
          }
      }'
    end

    def page3_response
      '{
          "_links": {
              "self": { "href": "/page3" },
              "posts": { "href": "/posts_of_page3" },
              "api:authors": { "href": "/authors" }
          }
      }'
    end
  end
end
