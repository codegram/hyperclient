require_relative 'test_helper'
require 'hyperclient'

describe Hyperclient do
  let(:api) do
    @klass = Class.new
    @klass.instance_eval do 
      include Hyperclient

      entry_point 'http://api.example.org'
    end

    @klass.new
  end

  describe 'entry point' do
    it 'allows to set an entry point for an API' do
      klass = Class.new do
        include Hyperclient
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
end