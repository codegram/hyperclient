# Hyperclient

[![Gem Version](http://img.shields.io/gem/v/hyperclient.svg)](http://badge.fury.io/rb/hyperclient)
[![Build Status](https://github.com/codegram/hyperclient/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/codegram/hyperclient/actions/workflows/test.yml)
[![Coverage Status](https://coveralls.io/repos/github/codegram/hyperclient/badge.svg?branch=master)](https://coveralls.io/github/codegram/hyperclient?branch=master)

Hyperclient is a Hypermedia API client written in Ruby. It fully supports [JSON HAL](http://stateless.co/hal_specification.html).

# Table of Contents

- [Usage](#usage)
  - [API Client](#api-client)
  - [Resources and Attributes](#resources-and-attributes)
  - [Links and Embedded Resources](#links-and-embedded-resources)
  - [Templated Links](#templated-links)
  - [Curies](#curies)
  - [Attributes](#attributes)
  - [HTTP](#http)
- [Testing Using Hyperclient](#testing-using-hyperclient)
- [Reference](#reference)
- [Hyperclient Users](#hyperclient-users)
- [Contributing](#contributing)
- [License](#license)

# Usage

The examples in this README use the [local Oxford HAL demo](examples/oxford/README.md), based on historical Oxford place facts. Start it with `bundle exec ruby examples/oxford/server.rb`, then run `bundle exec ruby -Ilib examples/oxford/client.rb` in another terminal. No external service is needed. Use version 1.x with Faraday 1.x, and version 2.x with Faraday 2.x. If you're upgrading from a previous version, please make sure to read [UPGRADING](UPGRADING.md).

Hyperclient is tested with JSON 2.x on Ruby 2.7, both JSON 2.x and 3.x on Ruby 3.2, and JSON 3.x on newer Rubies. JSON 3.x requires a Faraday release with keyword parser options support (2.14.4+).

## API Client

Create an API client.

```ruby
require 'hyperclient'

api = Hyperclient.new('http://127.0.0.1:9292/')
```

By default, Hyperclient adds `application/hal+json` as `Content-Type` and `Accept` headers. It will also send requests as JSON and parse JSON responses. Specify additional headers or authentication if necessary.

```ruby
api = Hyperclient.new('http://127.0.0.1:9292/') do |client|
  client.headers['Access-Token'] = 'token'
end
```

Hyperclient constructs a connection using typical [Faraday](http://github.com/lostisland/faraday) middleware for handling JSON requests and responses. You can specify additional Faraday middleware if necessary.

```ruby
api = Hyperclient.new('http://127.0.0.1:9292/') do |client|
  client.connection do |conn|
    conn.use Faraday::Request::Instrumentation
  end
end
```

You can pass options to the Faraday connection block in the `connection` block:

```ruby
api = Hyperclient.new('http://127.0.0.1:9292/') do |client|
  client.connection(ssl: { verify: false }) do |conn|
    conn.use Faraday::Request::Instrumentation
  end
end
```

Or when using the default connection configuration you can use `faraday_options`:

```ruby
api = Hyperclient.new('http://127.0.0.1:9292/') do |client|
  client.faraday_options = { ssl: { verify: false } }
end
```

You can build a new Faraday connection block without inheriting default middleware by specifying `default: false` in the `connection` block.

```ruby
api = Hyperclient.new('http://127.0.0.1:9292/') do |client|
  client.connection(default: false) do |conn|
    conn.request :json
    conn.response :json, content_type: /\bjson$/
    conn.adapter :net_http
  end
end
```

By default, Hyperclient requires responses to have a `Content-Type` of `application/hal+json`, and raises `Hyperclient::InvalidRepresentationError` otherwise. If your API sometimes returns responses that aren't `hal+json` (e.g. an empty body with a `201 Created`, or a plain `application/json` response), broaden the response middleware's `content_type` matcher as shown above (`content_type: /\bjson$/`) instead of the default, which only matches `hal+json`.

You can modify headers or specify authentication after a connection has been created. Hyperclient supports Basic, Token or [Digest auth](https://github.com/bhaberer/faraday-digestauth) as well as many other Faraday extensions.

```ruby
require 'faraday/digestauth'

api = Hyperclient.new('http://127.0.0.1:9292/') do |client|
  client.connection(default: false) do |conn|
    conn.request :digest, 'username', 'password'
    conn.request :json
    conn.response :json, content_type: /\bjson$/
    conn.adapter :net_http
  end
end
```

You can access the Faraday connection directly after it has been created and add middleware to it. As an example, you could use the [faraday-http-cache-middleware](https://github.com/plataformatec/faraday-http-cache).

```ruby
api = Hyperclient.new('http://127.0.0.1:9292/')
api.connection.use :http_cache
```

## Resources and Attributes

Hyperclient will fetch and discover the resources from your API and automatically paginate when possible.

```ruby
api.places.each do |place|
  puts "#{place.name} has ID #{place.id}."
end
```

Other methods, including `[]` and `fetch` are also available

```ruby
api.places.each do |place|
  puts "A place with ID #{place[:id]}."
  puts "Address: #{place.fetch(:address, '-- no address')}"
end
```

## Links and Embedded Resources

The example above follows the `places` link to a collection of embedded places. Hyperclient resolves links and embedded resources automatically. You can also navigate explicitly:

```ruby
api._links.places._embedded.places.each do |place|
  puts place.name
end

place = api.place(id: 'oxpoints:23232339')
puts place.primary_place.name # follows a relative link to Balliol College
puts place._embedded.files.first.url # reads embedded metadata, without fetching the image
```

## Templated Links

Templated links require variables to be expanded. The local demo adds a `place` link that accepts an Oxford place ID.

```ruby
place = api.place(id: 'oxpoints:23232339')
puts place.name # => Balliol College
```

Invoking `api.place(id: 'oxpoints:23232339').name` is equivalent to `api._links.place._expand(id: 'oxpoints:23232339')._resource._attributes.name`.

The client is responsible for supplying all the necessary parameters. Templated links don't do any strict parameter name checking and don't support required vs. optional parameters. Parameters not declared by the API will be dropped and will not have any effect when passed to `_expand`.

## Curies

Curies provide compact names for relation documentation. The local demo adds an `oxford` CURIE and an `oxford:places` relation.

```ruby
puts api._links['oxford:places']._embedded.places.first.name # => Balliol College
puts api._links._curies['oxford'].expand('places') # => /docs/places
```

## Attributes

Resource attributes can also be accessed as a hash.

```ruby
puts place.to_h['name'] # => Balliol College
```

`place.to_h` is equivalent to `place._attributes.to_h`.

## HTTP

Hyperclient uses [Faraday](http://github.com/lostisland/faraday) under the hood to perform HTTP calls. You can call any valid HTTP method on any resource.

For example, you can examine the API raw JSON by invoking `_get` and examining the `_response.body` hash.

```ruby
api._get
api._response.body
```

Other methods, including `_head` or `_options` are also available.

```ruby
place = api.place(id: 'oxpoints:23232339')
place._head
```

The Oxford demo is read-only and rejects writes with HTTP 405. On a writable API, invoke `_post` to create resources:

```ruby
api.places._post(name: 'New place')
```

Invoke `_put` or `_patch` to update resources.

```ruby
place._put(name: 'Updated place')
place._patch(name: 'Updated place')
```

Invoke `_delete` to destroy a resource.

```
place._delete
```

HTTP methods always return a new instance of Resource.

# Testing Using Hyperclient

You can combine RSpec, Faraday::Adapter::Rack and Hyperclient to test your HAL API without having to ever examine the raw JSON response.

```ruby
describe Acme::Api do
  def app
    Acme::App.instance
  end

  let(:client) do
    Hyperclient.new('http://example.org/api') do |client|
      client.headers['Content-Type'] = 'application/json'
      client.connection(default: false) do |conn|
        conn.request :json
        conn.response :json
        conn.use Faraday::Adapter::Rack, app
      end
    end
  end

  it 'returns a place' do
    expect(client.places.first.name).to eq 'Balliol College'
  end
end
```

For a complete offline example, see the [Oxford demo smoke test](test/oxford_example_test.rb).

# Reference

[Hyperclient API Reference](http://rubydoc.org/github/codegram/hyperclient/master/frames).

# Hyperclient Users

Using Hyperclient? Add your project to our wiki, please: <https://github.com/codegram/hyperclient/wiki>.

# Contributing

Hyperclient is work of [many people](https://github.com/codegram/hyperclient/graphs/contributors). You're encouraged to submit [pull requests](https://github.com/codegram/hyperclient/pulls), [propose features and discuss issues](https://github.com/codegram/hyperclient/issues). See [CONTRIBUTING](CONTRIBUTING.md) for details.

# License

MIT License, see [LICENSE](LICENSE) for details.

Copyright (c) 2012-2018 Oriol Gual, [Codegram Technologies](http://codegram.com) and Contributors
