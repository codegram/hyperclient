class Spinach::Features::DefaultConfig < Spinach::FeatureSteps
  include API

  step 'I use the default hyperclient config' do
    @api = Hyperclient.new('http://api.example.org')
  end

  step 'the request should have been sent with the correct JSON headers' do
    assert_requested :get, 'api.example.org', headers: {
      'Content-Type' => 'application/hal+json', 'Accept' => 'application/hal+json,application/json'
    }
  end

  step 'I send some data to the API' do
    stub_request(:post, 'http://api.example.org/posts').to_return(headers: { 'Content-Type' => 'application/hal+json' })
    assert_equal 200, api._links.posts._post(title: 'My first blog post')._response.status
  end

  step 'it should have been encoded as JSON' do
    assert_requested :post, 'api.example.org/posts', body: '{"title":"My first blog post"}'
  end

  step 'I get some data from the API' do
    @posts = api._links.posts
  end

  step 'it should have been parsed as JSON' do
    assert_equal 4, @posts._attributes.total_posts.to_i
    assert_equal 4, @posts._attributes['total_posts'].to_i
  end
end
