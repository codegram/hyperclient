class Spinach::Features::DefaultConfig < Spinach::FeatureSteps
  include WebMock::API
  attr_reader :api

  before do
    stub_request(:any, 'api.example.org')
  end

  step 'I use the default hyperclient config' do
    @api = Hyperclient.new('http://api.example.org')
  end

  step 'I connect with the API' do
    api.links
  end

  step 'the request should have been sent with the correct JSON headers' do
    assert_requested :get, 'api.example.org', headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
  end
end
