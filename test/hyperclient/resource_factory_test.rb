require_relative '../test_helper'
require 'hyperclient/resource_factory'

module Hyperclient
  describe ResourceFactory do
    let(:resource) do
      ResourceFactory.resource('/path/to/resource')
    end

    before do
      Hyperclient::Resource.entry_point = 'http://myapi.org'
    end

    describe 'resource' do
      it 'creates a new resource when is not present in the identity map' do
        resource = ResourceFactory.resource('/path/to/resource')

        resource.url.must_include '/path/to/resource'
      end

      it 'returns the resource when is already present in the identity map' do
        new_resource = ResourceFactory.resource('/path/to/resource')

        new_resource.object_id.must_equal resource.object_id
      end

      it 'raises if the given url is nil' do
        proc { ResourceFactory.resource(nil) }.must_raise MissingURLException
      end
    end
  end
end
