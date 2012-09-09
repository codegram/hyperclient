require_relative '../test_helper'
require 'hyperclient/link'

module Hyperclient
  describe Link do
    describe 'templated?' do
      let(:entry_point) { stub('entry point') }

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
      let(:entry_point) { stub('entry point', config: config) }
      let(:config) { stub('config') }

      it 'builds a resource with the hyperlink representation' do
        HTTP.expects(:new).with('/link', config).returns(http)
        Resource.expects(:new).with({}, entry_point)

        Link.new({'href' => '/link'}, entry_point).resource
      end
    end

    describe 'templated' do
      it 'buils a resource with the templated URI representation' do
        link = Link.new({'href' => '/orders{?id}', 'templated' => true}, stub('entry_point'))

        templated_link = link.templated(id: '1')
        templated_link.url.must_equal '/orders?id=1'
      end

      it 'raises if no uri variables are given' do
        link = Link.new({'href' => '/orders{?id}', 'templated' => true}, stub('entry_point'))

        proc { link.resource }.must_raise MissingURITemplateVariablesException
      end
    end

    it 'delegates unkown methods to the resource' do
      link = Link.new({'href' => 'http://myapi.org/orders'}, stub('entry_point', :config => {:base_uri => '/'}))
      stub_request(:get, "http://myapi.org/orders")
      resource = mock('Resource')

      Resource.expects(:new).returns(resource).at_least_once
      resource.expects(:embedded)

      link.embedded
    end
  end
end
