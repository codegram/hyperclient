class Spinach::Features::ApiNavigation < Spinach::FeatureSteps
  include API

  step 'I should be able to navigate to posts and authors' do
    api._links.posts._resource
    api._links['api:authors']._resource

    assert_requested :get, 'http://api.example.org/posts'
    assert_requested :get, 'http://api.example.org/authors'
  end

  step 'I should be able to paginate posts' do
    assert_kind_of Enumerator, api.posts.each
    assert_equal 4, api.posts.to_a.count
    assert_requested :get, 'http://api.example.org/posts'
    assert_requested :get, 'http://api.example.org/posts?page=2'
    assert_requested :get, 'http://api.example.org/posts?page=3'
  end

  step 'I should be able to paginate authors' do
    assert_equal 1, api._links['api:authors'].to_a.count
    assert_requested :get, 'http://api.example.org/authors'
  end

  step 'I search for a post with a templated link' do
    api._links.search._expand(q: 'something')._resource
  end

  step 'the API should receive the request with all the params' do
    assert_requested :get, 'http://api.example.org/search?q=something'
  end

  step 'I search for posts by tag with a templated link' do
    api._links.tagged._expand(tags: %w[foo bar])._resource
  end

  step 'the API should receive the request for posts by tag with all the params' do
    assert_requested :get, 'http://api.example.org/search?tags=foo&tags=bar'
  end

  step 'I load a single post' do
    @post = api._links.posts._links.last_post
  end

  step 'I should be able to access it\'s title and body' do
    assert_kind_of String, @post._attributes.title
    assert_kind_of String, @post._attributes.body
  end

  step 'I should also be able to access it\'s embedded comments' do
    comment = @post._embedded.comments.first
    assert_kind_of String, comment._attributes.title
  end

  step 'I should be able to navigate to next page' do
    assert_equal '/posts_of_page2', api._links.next._links.posts._url
  end

  step 'I should be able to navigate to next page without links' do
    assert_equal '/posts_of_page2', api.next.posts._url
  end

  step 'I should be able to count embedded items' do
    assert_equal 2, api._links.posts._resource._embedded.posts.count
    assert_equal 2, api.posts._embedded.posts.count
    assert_equal 4, api.posts.count
    assert_equal 4, api.posts.map.count
  end

  step 'I should be able to iterate over embedded items' do
    count = 0
    api.posts.each do |_post|
      count += 1
    end
    assert_equal 4, count
  end
end
