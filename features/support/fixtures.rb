require 'json'

module Spinach
  module Fixtures
    def root_response
      '{
          "_links": {
              "self": { "href": "/" },
              "posts": { "href": "/posts" },
              "search": { "href": "/search{?q}", "templated": true },
              "tagged": { "href": "/search{?tags*}", "templated": true },
              "api:authors": { "href": "/authors" },
              "next": { "href": "/page2" }
          }
      }'
    end

    def authors_response
      '{
          "_links": {
            "self": { "href": "/authors" }
          },
          "_embedded": {
            "api:authors": [
              {
                "name": "Lorem Ipsum",
                "_links": {
                  "self": { "href": "/authors/1" }
                }
              }
            ]
          }
      }'
    end

    def posts_response
      '{
          "_links": {
            "self": { "href": "/posts" },
            "next": {"href": "/posts?page=2"},
            "last_post": {"href": "/posts/1"}
          },
          "total_posts": "4",
          "_embedded": {
            "posts": [
              {
                "title": "My first blog post",
                "body":  "Lorem ipsum dolor sit amet",
                "_links": {
                  "self": { "href": "/posts/1" }
                }
              },
              {
                "title": "My second blog post",
                "body":  "Lorem ipsum dolor sit amet",
                "_links": {
                  "self": { "href": "/posts/2" }
                }
              }
            ]
          }
      }'
    end

    def posts_page2_response
      '{
          "_links": {
            "self": { "href": "/posts?page=2" },
            "next": { "href": "/posts?page=3" }
          },
          "total_posts": "4",
          "_embedded": {
            "posts": [
              {
                "title": "My third blog post",
                "body":  "Lorem ipsum dolor sit amet",
                "_links": {
                  "self": { "href": "/posts/3" }
                }
              }
            ]
          }
      }'
    end

    def posts_page3_response
      '{
          "_links": {
            "self": { "href": "/posts?page=3" }
          },
          "total_posts": "4",
          "_embedded": {
            "posts": [
              {
                "title": "My third blog post",
                "body":  "Lorem ipsum dolor sit amet",
                "_links": {
                  "self": { "href": "/posts/4" }
                }
              }
            ]
          }
      }'
    end

    def post1_response
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

    def post2_response
      '{
          "_links": {
            "self": { "href": "/posts/2" }
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

    def post3_response
      '{
          "_links": {
            "self": { "href": "/posts/3" }
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
