require_relative '../test_helper'
require 'hyperclient/link'

module Hyperclient
  describe Link do
    let(:entry_point) { stub('Entry point', config: {base_uri: '/'}) }

    describe 'templated?' do
      it 'returns true if the link is templated' do
        link = Link.new({'templated' => true}, entry_point)

        link.templated?.must_equal true
      end

      it 'returns false if the link is not templated' do
        link = Link.new({}, entry_point)

        link.templated?.must_equal false
      end
    end

    describe 'resource' do
      let(:http) { mock('HTTP', get: {}) }

      it 'builds a resource with the hyperlink representation' do
        HTTP.expects(:new).returns(http, {})
        Resource.expects(:new).with({}, entry_point)

        Link.new({}, entry_point).resource
      end
    end

    describe 'expand' do
      it 'buils a Link with the templated URI representation' do
        link = Link.new({'href' => '/orders{?id}', 'templated' => true}, entry_point)

        Link.expects(:new).with(anything, entry_point, {id: '1'})
        link.expand(id: '1')
      end

      it 'raises if no uri variables are given' do
        link = Link.new({'href' => '/orders{?id}', 'templated' => true}, entry_point)

        proc { link.resource }.must_raise MissingURITemplateVariablesException
      end
    end

    describe 'url' do
      it 'raises when missing required uri_variables' do
        link = Link.new({'href' => '/orders{?id}', 'templated' => true}, entry_point)

        lambda { link.url }.must_raise MissingURITemplateVariablesException
      end

      it 'expands an uri template with variables' do
        link = Link.new({'href' => '/orders{?id}', 'templated' => true}, entry_point, {id: 1})

        link.url.must_equal '/orders?id=1'
      end

      it 'returns the link when no uri template' do
        link = Link.new({'href' => '/orders'}, entry_point)
        link.url.must_equal '/orders'
      end
    end

    describe 'method_missing' do
      before do
        stub_request(:get, "http://myapi.org/orders")
        Resource.expects(:new).returns(resource).at_least_once
      end

      let(:link) { Link.new({'href' => 'http://myapi.org/orders'}, entry_point) }
      let(:resource) { mock('Resource') }

      it 'delegates unkown methods to the resource' do
        resource.expects(:embedded)

        link.embedded
      end

      it 'raises an error when the method does not exist in the resource' do
        lambda { link.this_method_does_not_exist }.must_raise(NoMethodError)
      end

      it 'responds to missing methods' do
        resource.expects(:respond_to?).with('embedded').returns(true)
        link.respond_to?(:embedded).must_equal true
      end
    end
  end
end
