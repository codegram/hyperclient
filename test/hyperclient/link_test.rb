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

      describe 'when the link is templated' do

        it 'buils a resource with the templated URI representation' do
          HTTP.expects(:new).with('/orders?id=1').returns(http)
          Resource.expects(:new).with({})

          link = Link.new({'href' => '/orders{?id}', 'templated' => true})

          link.resource(id: '1')
        end

        it 'raises if no uri variables are given' do
          link = Link.new({'href' => '/orders{?id}', 'templated' => true})

          proc { link.resource }.must_raise MissingURITemplateVariablesException
        end
      end
    end
  end
end
