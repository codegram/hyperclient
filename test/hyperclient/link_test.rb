require_relative '../test_helper'
require 'hyperclient/link'

module Hyperclient
  describe Link do
    describe 'templated?' do
      it 'returns true if the link is templated' do
        link = Link.new('templated' => true)

        link.templated?.must_equal true
      end

      it 'returns false if the link is not templated' do
        link = Link.new({})

        link.templated?.must_equal false
      end
    end

    describe 'resource' do
      let(:http) { mock('HTTP', get: {}) }

      it 'builds a resource with the hyperlink representation' do
        HTTP.expects(:new).returns(http)
        Resource.expects(:new).with({})

        Link.new({}).resource
      end
    end

    describe 'templated' do
      it 'buils a resource with the templated URI representation' do
        link = Link.new({'href' => '/orders{?id}', 'templated' => true})

        templated_link = link.templated(id: '1')
        templated_link.url.must_equal '/orders?id=1'
      end

      it 'raises if no uri variables are given' do
        link = Link.new({'href' => '/orders{?id}', 'templated' => true})

        proc { link.resource }.must_raise MissingURITemplateVariablesException
      end
    end

    it 'delegates unkown methods to the resource' do
      link = Link.new({'href' => 'http://myapi.org/orders'})
      stub_request(:get, "http://myapi.org/orders")
      resource = mock('Resource')

      Resource.expects(:new).returns(resource).at_least_once
      resource.expects(:embedded)

      link.embedded
    end
  end
end
