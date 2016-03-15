# Hyperclient

[![Gem Version](http://img.shields.io/gem/v/hyperclient.svg)](http://badge.fury.io/rb/hyperclient)
[![Build Status](http://img.shields.io/travis/codegram/hyperclient.svg)](https://travis-ci.org/codegram/hyperclient)
[![Dependency Status](https://gemnasium.com/codegram/hyperclient.svg)](https://gemnasium.com/codegram/hyperclient)
[![Code Climate](https://codeclimate.com/github/codegram/hyperclient.svg)](https://codeclimate.com/github/codegram/hyperclient)
[![Coverage Status](https://img.shields.io/coveralls/codegram/hyperclient.svg)](https://coveralls.io/r/codegram/hyperclient?branch=master)

Hyperclient is a Hypermedia API client written in Ruby. It fully supports [JSON HAL](http://stateless.co/hal_specification.html).

## Usage

The examples in this README use the [Splines Demo API](https://github.com/dblock/grape-with-roar) running [here](https://grape-with-roar.herokuapp.com/api). If you're upgrading from a previous version, please make sure to read [UPGRADING](UPGRADING.md).

### API Client

Create an API client.

```ruby
require 'hyperclient'

api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api')
```

By default, Hyperclient adds `application/hal+json` as `Content-Type` and `Accept` headers. It will also send requests as JSON and parse JSON responses. Specify additional headers or authentication if necessary.

```ruby
api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api') do |client|
  client.headers['Access-Token'] = 'token'
end
```

Hyperclient constructs a connection using typical [Faraday](http://github.com/lostisland/faraday) middleware for handling JSON requests and responses. You can specify additional Faraday middleware if necessary.

```ruby
api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api') do |client|
  client.connection do |conn|
    conn.use Faraday::Request::OAuth
  end
end
```

You can pass options to the Faraday connection block in the `connection` block:

```ruby
api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api') do |client|
  client.connection(ssl: { verify: false }) do |conn|
    conn.use Faraday::Request::OAuth
  end
end
```

Or when using the default connection configuration you can use `faraday_options`:

```ruby
api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api') do |client|
  client.faraday_options = { ssl: { verify: false } }
end
```

You can build a new Faraday connection block without inheriting default middleware by specifying `default: false` in the `connection` block.

```ruby
api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api') do |client|
  client.connection(default: false) do |conn|
    conn.request :json
    conn.response :json, content_type: /\bjson$/
    conn.adapter :net_http
  end
end
```

You can modify headers or specify authentication after a connection has been created. Hyperclient supports Basic, Token or Digest auth as well as many other Faraday extensions.

```ruby
api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api')
api.digest_auth('username', 'password')
api.headers.update('Accept-Encoding' => 'deflate, gzip')
```

You can access the Faraday connection directly after it has been created and add middleware to it. As an example, you could use the [faraday-http-cache-middleware](https://github.com/plataformatec/faraday-http-cache).

```ruby
api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api')
api.connection.use :http_cache
```

### Resources and Attributes

Hyperclient will fetch and discover the resources from your API.

```ruby
api.splines.each do |spline|
  puts "A spline with ID #{spline.uuid}."
end
```

Other methods, including `[]` and `fetch` are also available

```ruby
api.splines.each do |spline|
  puts "A spline with ID #{spline[:uuid]}."
  puts "Maybe with reticulated: #{spline.fetch(:reticulated, '-- no reticulated')}"
end
```

### Links and Embedded Resources

The splines example above followed a link called "splines". While you can, you do not need to specify the HAL navigational structure, including links or embedded resources. Hyperclient will resolve these for you.  If you prefer, you can explicitly navigate the link structure via `_links`. In the following example the "splines" link leads to a collection of embedded splines. Invoking `api.splines` is equivalent to `api._links.splines._embedded.splines`.

```ruby
api._links.splines
```

### Templated Links

Templated links require variables to be expanded. For example, the demo API has a link called "spline" that requires a spline "uuid".

```ruby
spline = api.spline(uuid: 'uuid')
puts "Spline #{spline.uuid} is #{spline.reticulated ? 'reticulated' : 'not reticulated'}."
```

Invoking `api.spline(uuid: 'uuid').reticulated` is equivalent to `api._links.spline._expand(uuid: 'uuid')._resource._attributes.reticulated`.

The client is responsible for supplying all the necessary parameters. Templated links don't do any strict parameter name checking and don't support required vs. optional parameters. Parameters not declared by the API will be dropped and will not have any effect when passed to `_expand`.

### Curies

Curies are a suggested means by which to link documentation of a given resource. For example, the demo API contains very long links to images that use an "images" curie.

```ruby
puts spline['image:thumbnail'] # => https://grape-with-roar.herokuapp.com/api/splines/uuid/images/thumbnail.jpg
puts spline.links._curies['image'].expand('thumbnail') # => /docs/images/thumbnail
```

### Attributes

Resource attributes can also be accessed as a hash.

```ruby
puts spline.to_h # => {"uuid" => "uuid", "reticulated" => true}
```

The above is equivalent to `spline._attributes.to_h`.

### HTTP

Hyperclient uses [Faraday](http://github.com/lostisland/faraday) under the hood to perform HTTP calls. You can call any valid HTTP method on any resource.

For example, you can examine the API raw JSON by invoking `_get` and examining the `_response.body` hash.

```ruby
api._get
api._response.body
```

Other methods, including `_head` or `_options` are also available.

```ruby
spline = api.spline(uuid: 'uuid')
spline._head
spline._options
```

Invoke `_post` to create resources.

```ruby
splines = api.splines
splines._post(uuid: 'new uuid', reticulated: false)
```

Invoke `_put` or `_patch` to update resources.

```ruby
spline = api.spline(uuid: 'uuid')
spline._put(reticulated: true)
spline._patch(reticulated: true)
```

Invoke `_delete` to destroy a resource.

```
spline = api.spline(uuid: 'uuid')
spline._delete
```

HTTP methods always return a new instance of Resource.

## Testing Using Hyperclient

You can combine RSpec, Faraday::Adapter::Rack and Hyperclient to test your HAL API without having to ever examine the raw JSON response.

```ruby
describe Acme::Api do
  def app
    Acme::App.instance
  end

  let(:client) do
    Hyperclient.new('http://example.org/api') do |client|
      client.connection(default: false) do |conn|
        conn.request :json
        conn.response :json
        conn.use Faraday::Adapter::Rack, app
      end
    end
  end

  it 'splines returns 3 splines by default' do
    expect(client.splines.count).to eq 3
  end
end
```

For a complete example refer to [this Splines Demo API test](https://github.com/dblock/grape-with-roar/blob/master/spec/api/splines_endpoint_with_hyperclient_spec.rb).

## Reference

[Hyperclient API Reference](http://rubydoc.org/github/codegram/hyperclient/master/frames).

## Contributing

Hyperclient is work of [many people](https://github.com/codegram/hyperclient/graphs/contributors). You're encouraged to submit [pull requests](https://github.com/codegram/hyperclient/pulls), [propose features and discuss issues](https://github.com/codegram/hyperclient/issues). See [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

MIT License, see [LICENSE](LICENSE) for details. Copyright 2012-2014 [Codegram Technologies](http://codegram.com).
