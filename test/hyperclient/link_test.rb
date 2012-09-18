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

    describe 'templated' do
      it 'buils a resource with the templated URI representation' do
        link = Link.new({'href' => '/orders{?id}', 'templated' => true}, entry_point)

        Link.expects(:new).with(anything, entry_point, {id: '1'})
        link.templated(id: '1')
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

    it 'delegates unkown methods to the resource' do
      link = Link.new({'href' => 'http://myapi.org/orders'}, entry_point)
      stub_request(:get, "http://myapi.org/orders")
      resource = mock('Resource')

      Resource.expects(:new).returns(resource).at_least_once
      resource.expects(:embedded)

      link.embedded
    end
  end
end
