# Hyperclient

[![Build Status](https://secure.travis-ci.org/codegram/hyperclient.png)](http://travis-ci.org/codegram/hyperclient)
[![Dependency Status](https://gemnasium.com/codegram/hyperclient.png)](http://gemnasium.com/codegram/hyperclient)
[![Code Climate](https://codeclimate.com/github/codegram/hyperclient.png)](https://codeclimate.com/github/codegram/hyperclient)

Hyperclient is a Hypermedia API client written in Ruby. It fully supports [JSON HAL](http://stateless.co/hal_specification.html).

## Usage

The examples in this README use the [Splines Demo API](https://github.com/dblock/grape-with-roar) running [here](https://grape-with-roar.herokuapp.com/api).

### API Client

Create an API client.

```ruby
require 'hyperclient'

api = Hyperclient.new('https://grape-with-roar.herokuapp.com/api')
```

By default, Hyperclient adds `application/json` as `Content-Type` and `Accept` headers. It will also send requests as JSON and parse JSON responses. Specify additional headers or authentication if necessary.

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

### Curies

Curies are named tokens that you can define in the document and use to express curie relation URIs in a friendlier, more compact fashion. For example, the demo API contains very long links to images that use an "images" curie. Hyperclient handles curies and resolves these into full links automatically.

```ruby
puts spline['image:thumbnail'] # => https://grape-with-roar.herokuapp.com/api/splines/uuid/images/thumbnail.jpg
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

## Reference

[Hyperclient API Reference](http://rubydoc.org/github/codegram/hyperclient/master/frames).

## Contributing

Hyperclient is work of [many people](https://github.com/codegram/hyperclient/graphs/contributors). You're encouraged to submit [pull requests](https://github.com/codegram/hyperclient/pulls), [propose features and discuss issues](https://github.com/codegram/hyperclient/issues). See [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

MIT License, see [LICENSE](LICENSE) for details. Copyright 2012-2014 [Codegram Technologies](http://codegram.com).
