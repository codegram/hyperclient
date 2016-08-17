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
        it 'returns the property value' do
          link = Link.new('key', { prop => 'value' }, entry_point)
          link.send("_#{prop}").must_equal 'value'
        end

        it 'returns nil if the property is not present' do
          link = Link.new('key', {}, entry_point)
          link.send("_#{prop}").must_equal nil
        end
      end
    end

    describe '_templated?' do
      it 'returns true if the link is templated' do
        link = Link.new('key', { 'templated' => true }, entry_point)

        link._templated?.must_equal true
      end

      it 'returns false if the link is not templated' do
        link = Link.new('key', {}, entry_point)

        link._templated?.must_equal false
      end
    end

    describe '_variables' do
      it 'returns a list of required variables' do
        link = Link.new('key', { 'href' => '/orders{?id,owner}', 'templated' => true }, entry_point)

        link._variables.must_equal %w(id owner)
      end

      it 'returns an empty array for untemplated links' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        link._variables.must_equal []
      end
    end

    describe '_expand' do
      describe 'required argument' do
        it 'builds a Link with the templated URI representation' do
          link = Link.new('key', { 'href' => '/orders/{id}', 'templated' => true }, entry_point)
          link._expand(id: '1')._url.must_equal '/orders/1'
        end

        it 'expands an uri template without variables' do
          link = Link.new('key', { 'href' => '/orders/{id}', 'templated' => true }, entry_point)
          link._expand._url.must_equal '/orders/'
          link._url.must_equal '/orders/'
        end
      end

      describe 'query string argument' do
        it 'builds a Link with the templated URI representation' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)
          link._expand(id: '1')._url.must_equal '/orders?id=1'
        end

        it 'expands an uri template without variables' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)
          link._expand._url.must_equal '/orders'
          link._url.must_equal '/orders'
        end

        it 'does not expand unknown variables' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)
          link._expand(unknown: '1')._url.must_equal '/orders'
        end

        it 'only expands known variables' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)
          link._expand(unknown: '1', id: '2')._url.must_equal '/orders?id=2'
        end

        it 'only expands templated links' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => false }, entry_point)
          link._expand(id: '1')._url.must_equal '/orders{?id}'
        end
      end
    end

    describe '_url' do
      it 'expands an uri template without variables' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)

        link._url.must_equal '/orders'
      end

      it 'expands an uri template with variables' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, id: 1)

        link._url.must_equal '/orders?id=1'
      end

      it 'does not expand an uri template with unknown variables' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, unknown: 1)

        link._url.must_equal '/orders'
      end

      it 'only expands known variables in a uri template' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, unknown: 1, id: 2)

        link._url.must_equal '/orders?id=2'
      end

      it 'returns the link when no uri template' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)
        link._url.must_equal '/orders'
      end

      it 'aliases to_s to _url' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, id: 1)

        link.to_s.must_equal '/orders?id=1'
      end
    end

    describe '_resource' do
      it 'builds a resource with the link href representation' do
        Resource.expects(:new)

        link = Link.new('key', { 'href' => '/' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/') { [200, {}, nil] }
        end

        link._resource
      end
    end

    describe 'get' do
      it 'sends a GET request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        link._get.must_be_kind_of Resource
      end

      it 'raises exceptions by default' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/productions/1') { [400, {}, nil] }
        end

        lambda { link._get }.must_raise Faraday::ClientError
      end
    end

    describe '_options' do
      it 'sends a OPTIONS request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.options('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        link._options.must_be_kind_of Resource
      end
    end

    describe '_head' do
      it 'sends a HEAD request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.head('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        link._head.must_be_kind_of Resource
      end
    end

    describe '_delete' do
      it 'sends a DELETE request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.delete('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        link._delete.must_be_kind_of Resource
      end
    end

    describe '_post' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }

      it 'sends a POST request with the link url and params' do
        stub_request(entry_point.connection) do |stub|
          stub.post('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        link._post('foo' => 'bar').must_be_kind_of Resource
      end

      it 'defaults params to an empty hash' do
        stub_request(entry_point.connection) do |stub|
          stub.post('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        link._post.must_be_kind_of Resource
      end
    end

    describe '_put' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }

      it 'sends a PUT request with the link url and params' do
        stub_request(entry_point.connection) do |stub|
          stub.put('http://api.example.org/productions/1', '{"foo":"bar"}') { [200, {}, nil] }
        end

        link._put('foo' => 'bar').must_be_kind_of Resource
      end

      it 'defaults params to an empty hash' do
        stub_request(entry_point.connection) do |stub|
          stub.put('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        link._put.must_be_kind_of Resource
      end
    end

    describe '_patch' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }

      it 'sends a PATCH request with the link url and params' do
        stub_request(entry_point.connection) do |stub|
          stub.patch('http://api.example.org/productions/1', '{"foo":"bar"}') { [200, {}, nil] }
        end

        link._patch('foo' => 'bar').must_be_kind_of Resource
      end

      it 'defaults params to an empty hash' do
        stub_request(entry_point.connection) do |stub|
          stub.patch('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        link._patch.must_be_kind_of Resource
      end
    end

    describe 'inspect' do
      it 'outputs a custom-friendly output' do
        link = Link.new('key', { 'href' => '/productions/1' }, 'foo')

        link.inspect.must_include 'Link'
        link.inspect.must_include '"href"=>"/productions/1"'
      end
    end

    describe 'method_missing' do
      describe 'delegation' do
        it 'delegates when link key matches' do
          resource = Resource.new({ '_links' => { 'orders' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { '_embedded' => { 'orders' => [{ 'id' => 1 }] } }] }
          end

          resource.orders._embedded.orders.first.id.must_equal 1
          resource.orders.first.id.must_equal 1
        end

        it "doesn't delegate when link key doesn't match" do
          resource = Resource.new({ '_links' => { 'foos' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { '_embedded' => { 'orders' => [{ 'id' => 1 }] } }] }
          end

          resource.foos._embedded.orders.first.id.must_equal 1
          resource.foos.first.must_equal nil
        end

        it 'backtracks when navigating links' do
          resource = Resource.new({ '_links' => { 'next' => { 'href' => '/page2' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/page2') { [200, {}, { '_links' => { 'next' => { 'href' => 'http://api.example.org/page3' } } }] }
          end

          resource.next._links.next._url.must_equal 'http://api.example.org/page3'
        end
      end

      describe 'resource' do
        before do
          stub_request(entry_point.connection) do |stub|
            stub.get('http://myapi.org/orders') { [200, {}, '{"resource": "This is the resource"}'] }
          end

          Resource.stubs(:new).returns(resource)
        end

        let(:resource) { mock('Resource') }
        let(:link) { Link.new('orders', { 'href' => 'http://myapi.org/orders' }, entry_point) }

        it 'delegates unkown methods to the resource' do
          Resource.expects(:new).returns(resource).at_least_once
          resource.expects(:embedded)

          link.embedded
        end

        it 'raises an error when the method does not exist in the resource' do
          lambda { link.this_method_does_not_exist }.must_raise NoMethodError
        end

        it 'responds to missing methods' do
          resource.expects(:respond_to?).with('orders').returns(false)
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
end
