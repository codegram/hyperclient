require_relative 'test_helper'
require 'hyperclient'

module Hyperclient
  describe EntryPoint do
    let(:api) do
      EntryPoint.new 'http://my.api.org'
    end

    describe 'entry' do
      it 'initializes a Resource at the entry point' do
        api.links['self'].href.must_equal 'http://my.api.org'
      end
    end

    describe 'auth' do
      it 'sets authentication type' do
        api.auth(:digest, nil, nil)

        api.http_options[:auth][:type].must_equal :digest
      end

      it 'sets the authentication credentials' do
        api.auth(:digest, 'user', 'secret')

        api.http_options[:auth][:credentials].must_include 'user'
        api.http_options[:auth][:credentials].must_include 'secret'
      end
    end

    describe 'method missing' do
      class Hyperclient::Resource
        def foo
          'foo'
        end
      end

      it 'delegates undefined methods to the API when they exist' do
        api.foo.must_equal 'foo'
      end

      it 'raises an error when the method does not exist in the API' do
        lambda { api.new.this_method_does_not_exist }.must_raise(NoMethodError)
      end
    end
  end
end