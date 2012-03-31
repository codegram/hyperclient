require_relative 'test_helper'

describe HyperClient do
  let(:api) do
    @klass = Class.new
    @klass.instance_eval do 
      include HyperClient

      entry_point 'http://api.example.org'
    end

    @klass.new
  end

  describe 'entry point' do
    it 'allows to set an entry point for an API' do
      klass = Class.new do
        include HyperClient
        entry_point 'http://api.example.org'
      end

      klass.entry_point.to_s.must_equal 'http://api.example.org'
    end
  end

  describe 'resources' do
    before do
      stub_request(:get, 'api.example.org').
        to_return(body: File.new('test/fixtures/root.json'), status: 200)
    end

    it 'fetches resources from the entry point using JSON HAL' do
      resources = api.resources

      resources.length.must_equal 1
    end
  end

  describe HyperClient::Resource do
    let(:response) do
      JSON.parse(File.read('test/fixtures/element.json'))
    end

    let(:element) do
      HyperClient::Resource.new('http://api.example.org/productions/1', response)
    end

    it 'sets the resource url' do
      element.url.to_s.must_equal 'http://api.example.org/productions/1'
    end

    it 'sets the resource data' do
      element.data['title'].must_equal 'Real World ASP.NET MVC3'
    end

    it 'does not set links as data' do
      element.data.wont_include '_links'
    end

    it 'does not set embedded data as data' do
      element.data.wont_include '_embedded'
    end

    it 'crates the resource accessors' do
      element.must_respond_to :filter
      element.filter.must_be_kind_of HyperClient::Resource
    end

    it 'sets resource relations from links' do
      element.resources.must_include 'filter'
    end

    it 'also sets relations from embedded resources' do
      element.resources.must_include 'author'
      element.author.must_be_kind_of HyperClient::Resource
    end

    it 'extracts collection resources from embedded resources' do
      element.episodes.length.must_equal 2
      element.episodes.first.must_be_kind_of HyperClient::Resource
    end

    it 'extracts collection resources from links resources' do
      element.episodes.first.media.length.must_equal 2
      element.episodes.first.media.first.must_be_kind_of HyperClient::Resource
    end

    it 'does not set self as a relation' do
      element.resources.wont_include 'self'
    end

    describe 'get' do
      it 'sends a GET request to the resource link' do
        stub_request(:get, 'api.example.org/productions/1').
          to_return(body: 'This is the element')

        body = element.get

        body.must_equal 'This is the element'
      end
    end
  end
end