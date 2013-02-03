class Spinach::Features::DefaultConfig < Spinach::FeatureSteps
  include API

  step 'I use the default hyperclient config' do
    @api = Hyperclient.new('http://api.example.org')
  end

  step 'the request should have been sent with the correct JSON headers' do
    assert_requested :get, 'api.example.org', headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
  end

  step 'I send some data to the API' do
    stub_request(:post, "http://api.example.org/posts")
    api.links.posts.post({title: 'My first blog post'})
  end

  step 'it should have been encoded as JSON' do
    assert_requested :post, 'api.example.org/posts', body: '{"title":"My first blog post"}'
  end

  step 'I get some data from the API' do
    @posts = api.links.posts
  end

  step 'it should have been parsed as JSON' do
    @posts.attributes.total_posts.to_i.must_equal 9
    @posts.attributes['total_posts'].to_i.must_equal 9
  end
end
