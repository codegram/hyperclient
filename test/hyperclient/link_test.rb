require_relative '../test_helper'
require 'hyperclient'

module Hyperclient
  describe Link do
    let(:entry_point) do
      EntryPoint.new('http://api.example.org/')
    end

    %w[type deprecation name profile title hreflang].each do |prop|
      describe prop do
        it 'returns the property value' do
          link = Link.new('key', { prop => 'value' }, entry_point)

          _(link.send("_#{prop}")).must_equal 'value'
        end

        it 'returns nil if the property is not present' do
          link = Link.new('key', {}, entry_point)

          _(link.send("_#{prop}")).must_be_nil
        end
      end
    end

    describe '_templated?' do
      it 'returns true if the link is templated' do
        link = Link.new('key', { 'templated' => true }, entry_point)

        _(link._templated?).must_equal true
      end

      it 'returns false if the link is not templated' do
        link = Link.new('key', {}, entry_point)

        _(link._templated?).must_equal false
      end
    end

    describe '_variables' do
      it 'returns a list of required variables' do
        link = Link.new('key', { 'href' => '/orders{?id,owner}', 'templated' => true }, entry_point)

        _(link._variables).must_equal %w[id owner]
      end

      it 'returns an empty array for untemplated links' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        _(link._variables).must_equal []
      end
    end

    describe '_expand' do
      describe 'required argument' do
        it 'builds a Link with the templated URI representation' do
          link = Link.new('key', { 'href' => '/orders/{id}', 'templated' => true }, entry_point)

          _(link._expand(id: '1')._url).must_equal '/orders/1'
        end

        it 'expands an uri template without variables' do
          link = Link.new('key', { 'href' => '/orders/{id}', 'templated' => true }, entry_point)

          _(link._expand._url).must_equal '/orders/'
          _(link._url).must_equal '/orders/'
        end
      end

      describe 'query string argument' do
        it 'builds a Link with the templated URI representation' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)

          _(link._expand(id: '1')._url).must_equal '/orders?id=1'
        end

        it 'expands an uri template without variables' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)

          _(link._expand._url).must_equal '/orders'
          _(link._url).must_equal '/orders'
        end

        it 'does not expand unknown variables' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)

          _(link._expand(unknown: '1')._url).must_equal '/orders'
        end

        it 'only expands known variables' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)

          _(link._expand(unknown: '1', id: '2')._url).must_equal '/orders?id=2'
        end

        it 'only expands templated links' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => false }, entry_point)

          _(link._expand(id: '1')._url).must_equal '/orders{?id}'
        end
      end
    end

    describe '_query' do
      it 'adds query parameters to a link that is not templated' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        _(link._query(sort: 'name')._url).must_equal '/orders?sort=name'
      end

      it 'adds query parameters a templated link does not declare' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)

        _(link._expand(id: '1')._query(sort: 'name')._url).must_equal '/orders?id=1&sort=name'
      end

      it 'keeps query parameters when expanded afterwards' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)

        _(link._query(sort: 'name')._expand(id: '1')._url).must_equal '/orders?id=1&sort=name'
      end

      it 'keeps the existing query string and fragment' do
        link = Link.new('key', { 'href' => '/orders?status=open&status=paid#top' }, entry_point)

        _(link._query(sort: 'name')._url).must_equal '/orders?status=open&status=paid&sort=name#top'
      end

      it 'combines chained query parameters' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        _(link._query(sort: 'name')._query(page: 2, sort: 'date')._url).must_equal '/orders?sort=date&page=2'
      end

      it 'encodes values and repeats array parameters' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        _(link._query(q: 'a&b c', ids: [1, 2])._url).must_equal '/orders?q=a%26b+c&ids=1&ids=2'
      end

      it 'drops nil and empty query parameters' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        _(link._query(sort: nil)._url).must_equal '/orders'
        _(link._query({})._url).must_equal '/orders'
      end

      it 'does not change the original link' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)
        link._query(sort: 'name')

        _(link._url).must_equal '/orders'
      end

      it 'sends the query parameters with the request' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/orders?sort=name') { [200, {}, { 'sorted' => true }] }
        end

        _(link._query(sort: 'name')._get.sorted).must_equal true
      end
    end

    describe '_url' do
      it 'expands an uri template without variables' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)

        _(link._url).must_equal '/orders'
      end

      it 'expands an uri template with variables' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, id: 1)

        _(link._url).must_equal '/orders?id=1'
      end

      it 'does not expand an uri template with unknown variables' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, unknown: 1)

        _(link._url).must_equal '/orders'
      end

      it 'only expands known variables in a uri template' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, unknown: 1, id: 2)

        _(link._url).must_equal '/orders?id=2'
      end

      it 'returns the link when no uri template' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        _(link._url).must_equal '/orders'
      end

      it 'aliases to_s to _url' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, id: 1)

        _(link.to_s).must_equal '/orders?id=1'
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

      it 'fetches a fresh resource after a mutating request instead of returning the cached response (#107)' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.post('http://api.example.org/productions/1') { [201, {}, { 'status' => 'created' }] }
          stub.get('http://api.example.org/productions/1') { [200, {}, { 'status' => 'fetched' }] }
        end

        link._post('foo' => 'bar')

        _(link._resource.status).must_equal 'fetched'
      end
    end

    describe 'get' do
      %w[application/hal+json application/json].each do |content_type|
        it "parses a #{content_type} response into a resource" do
          link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/productions/1') do
              [200, { 'Content-Type' => content_type },
               '{"title":"Production","_links":{"self":{"href":"/productions/1"}}}']
            end
          end

          resource = link._get

          _(resource.title).must_equal 'Production'
          _(resource._links.self._url).must_equal '/productions/1'
          _(resource._response.body).must_be_kind_of Hash
        end
      end

      it 'raises a parsing error for an invalid JSON response' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/productions/1') do
            [200, { 'Content-Type' => 'application/hal+json' }, '{"title":']
          end
        end

        _(-> { link._get }).must_raise Faraday::ParsingError
      end

      it 'sends a GET request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        _(link._get).must_be_kind_of Resource
      end

      it 'raises exceptions by default' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/productions/1') { [400, {}, nil] }
        end

        _(-> { link._get }).must_raise Faraday::ClientError
      end
    end

    describe '_options' do
      it 'sends a OPTIONS request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.options('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        _(link._options).must_be_kind_of Resource
      end
    end

    describe '_head' do
      it 'sends a HEAD request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.head('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        _(link._head).must_be_kind_of Resource
      end
    end

    describe '_delete' do
      it 'sends a DELETE request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.delete('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        _(link._delete).must_be_kind_of Resource
      end
    end

    describe '_post' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }

      it 'sends a POST request with the link url and params' do
        stub_request(entry_point.connection) do |stub|
          stub.post('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        _(link._post('foo' => 'bar')).must_be_kind_of Resource
      end

      it 'defaults params to an empty hash' do
        stub_request(entry_point.connection) do |stub|
          stub.post('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        _(link._post).must_be_kind_of Resource
      end
    end

    describe '_put' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }

      it 'sends a PUT request with the link url and params' do
        stub_request(entry_point.connection) do |stub|
          stub.put('http://api.example.org/productions/1', '{"foo":"bar"}') { [200, {}, nil] }
        end

        _(link._put('foo' => 'bar')).must_be_kind_of Resource
      end

      it 'defaults params to an empty hash' do
        stub_request(entry_point.connection) do |stub|
          stub.put('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        _(link._put).must_be_kind_of Resource
      end
    end

    describe '_patch' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }

      it 'sends a PATCH request with the link url and params' do
        stub_request(entry_point.connection) do |stub|
          stub.patch('http://api.example.org/productions/1', '{"foo":"bar"}') { [200, {}, nil] }
        end

        _(link._patch('foo' => 'bar')).must_be_kind_of Resource
      end

      it 'defaults params to an empty hash' do
        stub_request(entry_point.connection) do |stub|
          stub.patch('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        _(link._patch).must_be_kind_of Resource
      end
    end

    describe 'Allow header' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }
      let(:url) { 'http://api.example.org/productions/1' }

      it 'does not know the allowed methods before a request' do
        _(link._allow).must_be_nil
        _(link._allow?(:delete)).must_equal true
      end

      it 'sends any method when the response has no Allow header' do
        stub_request(entry_point.connection) do |stub|
          stub.get(url) { [200, {}, nil] }
          stub.delete(url) { [204, {}, nil] }
        end

        link._get

        _(link._allow).must_be_nil
        _(link._delete).must_be_kind_of Resource
      end

      it 'parses methods case-insensitively, ignoring whitespace and empty entries' do
        stub_request(entry_point.connection) do |stub|
          stub.get(url) { [200, { 'allow' => ' get,head ,, Post,get ' }, nil] }
        end

        link._get

        _(link._allow).must_equal %w[GET HEAD POST]
        _(link._allow?(:post)).must_equal true
        _(link._allow?('Head')).must_equal true
        _(link._allow?(:delete)).must_equal false
      end

      it 'sends a method that the Allow header does not list by default' do
        stub_request(entry_point.connection) do |stub|
          stub.get(url) { [200, { 'Allow' => 'GET, HEAD' }, nil] }
          stub.delete(url) { [204, {}, nil] }
        end

        link._get

        _(entry_point.enforce_allowed_methods?).must_equal false
        _(link._allow?(:delete)).must_equal false
        _(link._delete).must_be_kind_of Resource
      end

      it 'repeats a request that returned 405 by default' do
        requests = 0
        stub_request(entry_point.connection) do |stub|
          stub.delete(url) do
            requests += 1
            [405, { 'Allow' => 'GET' }, nil]
          end
        end

        _(-> { link._delete }).must_raise Faraday::ClientError
        _(link._allow).must_equal %w[GET]
        _(-> { link._delete }).must_raise Faraday::ClientError
        _(requests).must_equal 2
      end

      it 'returns a copy of the allowed methods' do
        stub_request(entry_point.connection) do |stub|
          stub.get(url) { [200, { 'Allow' => 'GET' }, nil] }
        end

        link._get
        link._allow << 'DELETE'

        _(link._allow?(:delete)).must_equal false
      end

      describe 'with enforce_allowed_methods' do
        before do
          entry_point.enforce_allowed_methods = true
        end

        it 'sends an allowed method' do
          stub_request(entry_point.connection) do |stub|
            stub.get(url) { [200, { 'Allow' => 'GET, POST' }, nil] }
            stub.post(url) { [201, {}, nil] }
          end

          link._get

          _(link._post('foo' => 'bar')).must_be_kind_of Resource
        end

        it 'raises MethodNotAllowedError without sending a disallowed method' do
          stub_request(entry_point.connection) do |stub|
            stub.get(url) { [200, { 'Allow' => 'GET, HEAD' }, nil] }
          end

          link._get
          error = _(-> { link._delete }).must_raise MethodNotAllowedError

          _(error.http_method).must_equal 'DELETE'
          _(error.url).must_equal '/productions/1'
          _(error.allowed).must_equal %w[GET HEAD]
          _(error.message).must_equal 'DELETE is not allowed on /productions/1, the server allows only GET, HEAD.'
        end

        it 'raises for every method when the Allow header is empty, except OPTIONS' do
          stub_request(entry_point.connection) do |stub|
            stub.head(url) { [200, { 'Allow' => '' }, nil] }
            stub.options(url) { [200, { 'Allow' => 'GET' }, nil] }
            stub.get(url) { [200, {}, nil] }
          end

          link._head

          _(link._allow).must_equal []
          error = _(-> { link._get }).must_raise MethodNotAllowedError
          _(error.message).must_equal 'GET is not allowed on /productions/1, the server allows no methods.'
          _(-> { link._head }).must_raise MethodNotAllowedError

          link._options

          _(link._allow).must_equal %w[GET]
          _(link._get).must_be_kind_of Resource
        end

        it 'does not imply HEAD from GET' do
          stub_request(entry_point.connection) do |stub|
            stub.get(url) { [200, { 'Allow' => 'GET' }, nil] }
          end

          link._get

          _(-> { link._head }).must_raise MethodNotAllowedError
        end

        it 'records the Allow header of a 405 response and refuses to repeat the request' do
          requests = 0
          stub_request(entry_point.connection) do |stub|
            stub.delete(url) do
              requests += 1
              [405, { 'Allow' => 'GET, PUT' }, nil]
            end
            stub.put(url) { [200, {}, nil] }
          end

          _(-> { link._delete }).must_raise Faraday::ClientError
          _(link._allow).must_equal %w[GET PUT]
          _(-> { link._delete }).must_raise MethodNotAllowedError
          _(requests).must_equal 1
          _(link._put('foo' => 'bar')).must_be_kind_of Resource
        end

        it 'records the Allow header of a 405 response when errors are not raised' do
          entry_point.connection(default: false) do |conn|
            conn.adapter :test do |stub|
              stub.post(url) { [405, { 'Allow' => 'GET' }, nil] }
            end
          end

          _(link._post._status).must_equal 405
          _(-> { link._post }).must_raise MethodNotAllowedError
        end

        it 'uses the most recent response' do
          stub_request(entry_point.connection) do |stub|
            stub.get(url) { [200, { 'Allow' => 'GET, PATCH' }, nil] }
            stub.patch(url) { [200, {}, nil] }
            stub.delete(url) { [204, {}, nil] }
          end

          link._get

          _(-> { link._delete }).must_raise MethodNotAllowedError
          link._patch('foo' => 'bar')

          _(link._allow).must_be_nil
          _(link._delete).must_be_kind_of Resource
        end

        it 'keeps the allowed methods per link' do
          stub_request(entry_point.connection) do |stub|
            stub.get(url) { [200, { 'Allow' => 'GET' }, nil] }
            stub.delete(url) { [204, {}, nil] }
          end

          link._get

          _(Link.new('key', { 'href' => '/productions/1' }, entry_point)._delete).must_be_kind_of Resource
        end

        it 'starts an expanded link without restrictions' do
          stub_request(entry_point.connection) do |stub|
            stub.get(url) { [200, { 'Allow' => 'GET' }, nil] }
            stub.delete(url) { [204, {}, nil] }
          end

          link._get

          _(-> { link._delete }).must_raise MethodNotAllowedError
          _(link._expand._allow).must_be_nil
          _(link._expand._delete).must_be_kind_of Resource
        end
      end
    end

    describe 'inspect' do
      it 'outputs a custom-friendly output' do
        link = Link.new('key', { 'href' => '/productions/1' }, 'foo')

        _(link.inspect).must_include 'Link'
        _(link.inspect).must_include({ 'href' => '/productions/1' }.inspect)
      end
    end

    describe 'method_missing' do
      describe 'delegation' do
        it 'delegates when link key matches' do
          resource = Resource.new({ '_links' => { 'orders' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { '_embedded' => { 'orders' => [{ 'id' => 1 }] } }] }
          end

          _(resource.orders._embedded.orders.first.id).must_equal 1
          _(resource.orders.first.id).must_equal 1
        end

        it 'can handle false values in the response' do
          resource = Resource.new({ '_links' => { 'orders' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { 'any' => false }] }
          end

          _(resource.orders.any).must_equal false
        end

        it "doesn't delegate when link key doesn't match" do
          resource = Resource.new({ '_links' => { 'foos' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { '_embedded' => { 'orders' => [{ 'id' => 1 }] } }] }
          end

          _(resource.foos._embedded.orders.first.id).must_equal 1
          _(resource.foos.first).must_be_nil
        end

        it 'backtracks when navigating links' do
          resource = Resource.new({ '_links' => { 'next' => { 'href' => '/page2' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/page2') { [200, {}, { '_links' => { 'next' => { 'href' => 'http://api.example.org/page3' } } }] }
          end

          _(resource.next._links.next._url).must_equal 'http://api.example.org/page3'
        end

        it 'iterates over paginated, embedded items across pages' do
          resource = Resource.new({ '_links' => { 'orders' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') do
              [200, {}, { '_links' => { 'next' => { 'href' => 'http://api.example.org/orders?page=2' } },
                          '_embedded' => { 'orders' => [{ 'id' => 1 }] } }]
            end
            stub.get('http://api.example.org/orders?page=2') do
              [200, {}, { '_embedded' => { 'orders' => [{ 'id' => 2 }] } }]
            end
          end

          ids = resource._links.orders.map(&:id)

          _(ids).must_equal [1, 2]
        end

        it 'raises a clear error when the resource links back to itself under the same name' do
          resource = Resource.new({ '_links' => { 'sub_nodes' => { 'href' => '/sub_nodes' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/sub_nodes') do
              [200, {}, { '_links' => { 'sub_nodes' => { 'href' => 'http://api.example.org/sub_nodes' } },
                          '_embedded' => { 'nodes' => [{ 'name' => 'a' }] } }]
            end
          end

          error = _(-> { resource._links.sub_nodes.map(&:name) }).must_raise Hyperclient::SelfReferencingLinkError
          _(error.message).must_equal 'The sub_nodes link at http://api.example.org/sub_nodes links back to itself, ' \
                                      'use _embedded to iterate over embedded items.'
          _(resource._links.sub_nodes._embedded.nodes.map(&:name)).must_equal ['a']
        end

        it 'does not follow a link back to itself when checking respond_to? or delegating' do
          resource = Resource.new({ '_links' => { 'sub_nodes' => { 'href' => '/sub_nodes' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/sub_nodes') do
              [200, {}, { 'name' => nil,
                          '_links' => { 'sub_nodes' => { 'href' => 'http://api.example.org/sub_nodes' } } }]
            end
          end

          _(resource._links.sub_nodes.respond_to?(:unknown)).must_equal false
          _(resource._links.sub_nodes.name).must_be_nil
        end

        it 'iterates a link that points to a different url with the same name' do
          resource = Resource.new({ '_links' => { 'orders' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { '_links' => { 'orders' => { 'href' => '/all_orders' } } }] }
            stub.get('http://api.example.org/all_orders') { [200, {}, { '_embedded' => { 'orders' => [{ 'id' => 1 }] } }] }
          end

          _(resource._links.orders.map(&:id)).must_equal [1]
        end

        it 'returns an Enumerator when called without a block' do
          resource = Resource.new({ '_links' => { 'orders' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { '_embedded' => { 'orders' => [{ 'id' => 1 }] } }] }
          end

          enum = resource._links.orders.each

          _(enum).must_be_kind_of Enumerator
          _(enum.to_a.first.id).must_equal 1
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
          _(-> { link.this_method_does_not_exist }).must_raise NoMethodError
        end

        it 'responds to missing methods' do
          resource.expects(:respond_to?).with('orders').returns(false)
          resource.expects(:respond_to?).with('embedded').returns(true)

          _(link.respond_to?(:embedded)).must_equal true
        end

        it 'responds to missing methods that delegate to another resource' do
          delegate = mock('Delegate')
          resource.expects(:respond_to?).with('orders').returns(true)
          resource.expects(:send).with('orders').returns(delegate)
          delegate.expects(:respond_to?).with('foo').returns(true)

          _(link.respond_to?(:foo)).must_equal true
        end

        it 'does not delegate to_ary to resource' do
          resource.expects(:to_ary).never

          _([[link, link]].flatten).must_equal [link, link]
        end

        it 'delegates through delegate_method when the resource responds but returns nil' do
          delegate = mock('Delegate')
          resource.expects(:respond_to?).with('foo').returns(true)
          resource.expects(:send).with(:foo).returns(nil)
          resource.expects(:respond_to?).with('orders').returns(true)
          resource.expects(:send).with('orders').returns(delegate)
          delegate.expects(:respond_to?).with('foo').returns(true)
          delegate.expects(:send).with(:foo).returns('delegated result')

          _(link.foo).must_equal 'delegated result'
        end

        it 'returns nil from delegate_method when the resource has no matching key' do
          keyless_link = Link.new(nil, { 'href' => 'http://myapi.org/orders' }, entry_point)
          resource.expects(:respond_to?).with('foo').returns(true)
          resource.expects(:send).with(:foo).returns(nil)

          _(keyless_link.foo).must_be_nil
        end

        it 'returns nil from delegate_method when the delegate does not respond to the method' do
          delegate = mock('Delegate')
          resource.expects(:respond_to?).with('foo').returns(true)
          resource.expects(:send).with(:foo).returns(nil)
          resource.expects(:respond_to?).with('orders').returns(true)
          resource.expects(:send).with('orders').returns(delegate)
          delegate.expects(:respond_to?).with('foo').returns(false)

          _(link.foo).must_be_nil
        end
      end
    end
  end
end
