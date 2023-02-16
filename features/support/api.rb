require_relative 'fixtures'
module API
  include Spinach::DSL
  include WebMock::API
  include Spinach::Fixtures

  before do
    WebMock::Config.instance.query_values_notation = :flat_array

    stub_request(:any, /api.example.org*/).to_return(body: root_response,
                                                     headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org').to_return(body: root_response,
                                                    headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org/authors').to_return(body: authors_response,
                                                            headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org/posts').to_return(body: posts_response,
                                                          headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org/posts?page=2').to_return(body: posts_page2_response,
                                                                 headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org/posts?page=3').to_return(body: posts_page3_response,
                                                                 headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org/posts/1').to_return(body: post1_response,
                                                            headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org/posts/2').to_return(body: post2_response,
                                                            headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org/posts/3').to_return(body: post3_response,
                                                            headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org/page2').to_return(body: page2_response,
                                                          headers: { 'Content-Type' => 'application/hal+json' })
    stub_request(:get, 'api.example.org/page3').to_return(body: page3_response,
                                                          headers: { 'Content-Type' => 'application/hal+json' })
  end

  def api
    @api ||= Hyperclient.new('http://api.example.org')
  end

  step 'I connect to the API' do
    api._links
  end

  after do
    WebMock.reset!
  end
end
