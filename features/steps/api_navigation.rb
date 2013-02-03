class Spinach::Features::ApiNavigation < Spinach::FeatureSteps
  include API

  step 'I should be able to navigate to posts and authors' do
    api.links.posts.resource
    api.links['api:authors'].resource

    assert_requested :get, 'http://api.example.org/posts'
    assert_requested :get, 'http://api.example.org/authors'
  end

  step 'I search for a post with a templated link' do
    api.links.search.expand(q: 'something').resource
  end

  step 'the API should receive the request with all the params' do
    assert_requested :get, 'http://api.example.org/search?q=something'
  end

  step 'I load a single post' do
    @post = api.links.posts.links.last_post
  end

  step 'I should be able to access it\'s title and body' do
    @post.attributes.title.wont_equal nil
    @post.attributes.body.wont_equal nil
  end

  step 'I should also be able to access it\'s embedded comments' do
    comment = @post.embedded.comments.first
    comment.attributes.title.wont_equal nil
  end
end
