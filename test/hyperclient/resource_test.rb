require_relative '../test_helper'
require 'hyperclient/resource'

describe Hyperclient::Resource do
  let(:response) do
    JSON.parse(File.read('test/fixtures/element.json'))
  end

  let(:element) do
    Hyperclient::Resource.base_uri = 'http://api.example.org'
    Hyperclient::Resource.new(response)
  end

  describe 'base_uri' do
    it 'sets the base uri for all the resources' do
      element.base_uri.to_s.must_equal 'http://api.example.org'
    end
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
    element.filter.must_be_kind_of Hyperclient::Resource
  end

  it 'sets resource relations from links' do
    element.resources.must_include 'filter'
  end

  it 'also sets relations from embedded resources' do
    element.resources.must_include 'author'
    element.author.must_be_kind_of Hyperclient::Resource
  end

  it 'extracts collection resources from embedded resources' do
    element.episodes.length.must_equal 2
    element.episodes.first.must_be_kind_of Hyperclient::Resource
  end

  it 'extracts collection resources from links resources' do
    element.episodes.first.media.length.must_equal 2
    element.episodes.first.media.first.must_be_kind_of Hyperclient::Resource
  end

  it 'does not set self as a relation' do
    element.resources.wont_include 'self'
  end

  describe 'get' do
    it 'sends a GET request to the resource link' do
      stub_request(:get, 'api.example.org/productions/1').
        to_return(body: 'This is the element')

      response = element.get
      response.body.must_equal 'This is the element'
      response.code.must_equal 200
    end
  end

  describe 'post' do
    it 'sends a POST request to the resource link' do
      stub_request(:post, 'api.example.org/productions/1').
        to_return(body: 'Posting like a big boy huh?', status: 201)

      response = element.post({})
      response.code.must_equal 201
    end
  end

  describe 'put' do
    it 'sends a PUT request'
  end

  describe 'options' do
    it 'sends a OPTION request'
  end

  describe 'head' do
    it 'sends a HEAD request'
  end

  describe 'delete' do
    it 'sends a DELETE request'
  end
end
