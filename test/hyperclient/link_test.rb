require_relative '../test_helper'
require 'hyperclient/link'
require 'hyperclient/entry_point'

module Hyperclient
  describe Link do
    let(:entry_point) do
      EntryPoint.new('http://api.example.org/')
    end

    %w(type deprecation name profile title hreflang).each do |prop|
      describe prop do
        it "returns the property value" do
          link = Link.new({prop => 'value'}, entry_point)
          link.send(prop).must_equal 'value'
        end

        it 'returns nil if the property is not present' do
          link = Link.new({}, entry_point)
          link.send(prop).must_equal nil
        end
      end
    end

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

    describe 'variables' do
      it 'returns a list of required variables' do
        link = Link.new({'href' => '/orders{?id,owner}', 'templated' => true}, entry_point)

        link.variables.must_equal ['id', 'owner']
      end

      it 'returns an empty array for untemplated links' do
        link = Link.new({'href' => '/orders'}, entry_point)

        link.variables.must_equal []
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

    describe 'resource' do
      it 'builds a resource with the link href representation' do
        mock_response = mock(body: {})

        Resource.expects(:new).with({}, entry_point, mock_response)

        link = Link.new({'href' => '/'}, entry_point)
        link.expects(:get).returns(mock_response)

        link.resource
      end
    end

    describe 'connection' do
      it 'returns the entry point connection' do
        Link.new({}, entry_point).connection.must_equal entry_point.connection
      end
    end

    describe 'get' do
      it 'sends a GET request with the link url' do
        link = Link.new({'href' => '/productions/1'}, entry_point)

        entry_point.connection.expects(:get).with('/productions/1')
        link.get
      end
    end

    describe 'options' do
      it 'sends a OPTIONS request with the link url' do
        link = Link.new({'href' => '/productions/1'}, entry_point)

        entry_point.connection.expects(:run_request).with(:options, '/productions/1', nil, nil)
        link.options
      end
    end

    describe 'head' do
      it 'sends a HEAD request with the link url' do
        link = Link.new({'href' => '/productions/1'}, entry_point)

        entry_point.connection.expects(:head).with('/productions/1')
        link.head
      end
    end

    describe 'delete' do
      it 'sends a DELETE request with the link url' do
        link = Link.new({'href' => '/productions/1'}, entry_point)

        entry_point.connection.expects(:delete).with('/productions/1')
        link.delete
      end
    end

    describe 'post' do
      let(:link) { Link.new({'href' => '/productions/1'}, entry_point) }

      it 'sends a POST request with the link url and params' do
        entry_point.connection.expects(:post).with('/productions/1', {'foo' => 'bar'})
        link.post({'foo' => 'bar'})
      end

      it 'defaults params to an empty hash' do
        entry_point.connection.expects(:post).with('/productions/1', {})
        link.post
      end
    end

    describe 'put' do
      let(:link) { Link.new({'href' => '/productions/1'}, entry_point) }

      it 'sends a PUT request with the link url and params' do
        entry_point.connection.expects(:put).with('/productions/1', {'foo' => 'bar'})
        link.put({'foo' => 'bar'})
      end

      it 'defaults params to an empty hash' do
        entry_point.connection.expects(:put).with('/productions/1', {})
        link.put
      end
    end

    describe 'patch' do
      let(:link) { Link.new({'href' => '/productions/1'}, entry_point) }

      it 'sends a PATCH request with the link url and params' do
        entry_point.connection.expects(:patch).with('/productions/1', {'foo' => 'bar'})
        link.patch({'foo' => 'bar'})
      end

      it 'defaults params to an empty hash' do
        entry_point.connection.expects(:patch).with('/productions/1', {})
        link.patch
      end
    end

    describe 'inspect' do
      it 'outputs a custom-friendly output' do
        link = Link.new({'href'=>'/productions/1'}, 'foo')

        link.inspect.must_include 'Link'
        link.inspect.must_include '"href"=>"/productions/1"'
      end
    end

    describe 'method_missing' do
      before do
        stub_request(:get, "http://myapi.org/orders").
          to_return(body: '{"resource": "This is the resource"}')
        Resource.stubs(:new).returns(resource)
      end

      let(:link) { Link.new({'href' => 'http://myapi.org/orders'}, entry_point) }
      let(:resource) { mock('Resource') }

      it 'delegates unkown methods to the resource' do
        Resource.expects(:new).returns(resource).at_least_once
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

      it 'does not delegate to_ary to resource' do
        resource.expects(:to_ary).never
        [[link, link]].flatten.must_equal [link, link]
      end
    end
  end
end
