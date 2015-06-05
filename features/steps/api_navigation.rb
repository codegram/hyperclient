class Spinach::Features::ApiNavigation < Spinach::FeatureSteps
  include API

  step 'I should be able to navigate to posts and authors' do
    api._links.posts._resource
    api._links['api:authors']._resource

    assert_requested :get, 'http://api.example.org/posts'
    assert_requested :get, 'http://api.example.org/authors'
  end

  step 'I search for a post with a templated link' do
    api._links.search._expand(q: 'something')._resource
  end

  step 'the API should receive the request with all the params' do
    assert_requested :get, 'http://api.example.org/search?q=something'
  end

  step 'I load a single post' do
    @post = api._links.posts._links.last_post
  end

  step 'I should be able to access it\'s title and body' do
    @post._attributes.title.wont_equal nil
    @post._attributes.body.wont_equal nil
  end

  step 'I should also be able to access it\'s embedded comments' do
    comment = @post._embedded.comments.first
    comment._attributes.title.wont_equal nil
  end

  step 'I should be able to navigate to next page' do
    assert_equal '/posts_of_page2', api._links.next._links.posts._url
  end

  step 'I should be able to navigate to next page without links' do
    assert_equal '/posts_of_page2', api.next.posts._url
  end
end
