require_relative 'test_helper'
require 'hyperclient'

describe Hyperclient do
  let(:api) do
    Class.new do
      include Hyperclient
    end
  end

  describe 'entry point' do
    it 'sets the entry point for Hyperclient::Resource' do
      api.entry_point {'http://my.api.org'}

      Hyperclient::Resource.new('/').url.must_include 'http://my.api.org'
    end
  end

  describe 'entry' do
    before do
      api.entry_point {'http://my.api.org'}
    end

    it 'initializes a Resource at the entry point' do
      api.new.entry.url.must_equal 'http://my.api.org'
    end

    it 'also works with entry points that are not in the root' do
      api.entry_point {'http://my.api.org/api'}
      api.new.entry.url.must_equal 'http://my.api.org/api'
    end

    it 'sets the Resource name' do
      api.new.name.must_equal 'Entry point'
    end
  end

  describe 'auth' do
    it 'sets authentication type' do
      api.auth{ {type: :digest, user: nil, password: nil} }

      api.http_options[:http][:auth][:type].must_equal :digest
    end

    it 'sets the authentication credentials' do
      api.auth{ {type: :digest, user: 'user', password: 'secret'} }

      api.http_options[:http][:auth][:credentials].must_include 'user'
      api.http_options[:http][:auth][:credentials].must_include 'secret'
    end
  end

  describe 'method missing' do
    class Hyperclient::Resource
      def foo
        'foo'
      end
    end

    it 'delegates undefined methods to the API when they exist' do
      api.new.foo.must_equal 'foo'
    end

    it 'raises an error when the method does not exist in the API' do
      lambda { api.new.this_method_does_not_exist }.must_raise(NoMethodError)
    end
  end
end