# Hyperclient
[![Build Status](https://secure.travis-ci.org/codegram/hyperclient.png)](http://travis-ci.org/codegram/hyperclient)
[![Dependency Status](https://gemnasium.com/codegram/hyperclient.png)](http://gemnasium.com/codegram/hyperclient)
[![Code Climate](https://codeclimate.com/github/codegram/hyperclient.png)](https://codeclimate.com/github/codegram/hyperclient)

Hyperclient is a Ruby Hypermedia API client written in Ruby.

## Usage

Example API client:

```ruby
api = Hyperclient.new('http://myapp.com/api').tap do |api|
  api.digest_auth('user', 'password')
  api.headers.update('accept-encoding' => 'deflate, gzip')
end
```

By default, Hyperclient adds `application/json` as `Content-Type` and `Accept` headers. It will also send requests as JSON and parse JSON responses.

## HAL

Hyperclient only works with JSON HAL friendly APIs. [Learn about JSON HAL](http://stateless.co/hal_specification.html).

## Resources

Hyperclient will try to fetch and discover the resources from your API.

### Links

Accessing the links for a given resource is quite straightforward:

```ruby
api._links.posts_categories
# => #<Resource ...>
```

Or omit `_links`, which will look for a link called "posts_categories" by default:

```ruby
api.posts_categories
# => #<Resource ...>
```

You can also iterate between all the links:

```ruby
api._links.each do |name, link|
  puts name, link._url
end
```

Actually, you can call any [Enumerable](http://ruby-doc.org/core-1.9.3/Enumerable.html) method :D

If a resource doesn't have friendly name you can always access it as a hash:

```ruby
api._links['http://myapi.org/rels/post_categories']
```

### Curies

Curies are named tokens that you can define in the document and use to express curie relation URIs in a friendlier, more compact fashion. Hyperclient handles curies automatically and resolves them into full links.

Access and expand curied links like any other link:

```ruby
api._links['image:thumbnail']._expand(version: 'small')
```

### Embedded resources

Accessing embedded resources is similar to accessing links:

```ruby
api._embedded.posts
```

Or omit the `_embedded` keyword. By default Hyperclient will look for a "posts" link, then for an embedded "posts" collection:

```ruby
api.posts
```

And you can also iterate between them:

```ruby
api.embedded.each do |name, resource|
  puts name, resource.attributes
end
```

You can even chain different calls (this also applies for links):

```ruby
api.embedded.posts.first.links.author
```

Or omit the navigational structures:

```ruby
api.posts.first.author
```

If you have a named link that retrieves an embedded collection of the same name, you can collapse the nested reference. The following statements produce identical results:

```ruby
api.links.posts.embedded.posts.first
```

```ruby
api.posts.first
```

### Attributes

Not only you might have links and embedded resources in a Resource, but also its attributes:

```ruby
api.embedded.posts.first.attributes
# => {title: 'Linting the hell out of your Ruby classes with Pelusa',
      teaser: 'Gain new insights about your code thanks to static analysis',
      body:   '...' }
```

You can access the attribute values via attribute methods, or as a hash:

```ruby
api.posts.first.title
# => 'Linting the hell out of your Ruby classes with Pelusa'

api.embedded.posts.first.attributes.title
# => 'Linting the hell out of your Ruby classes with Pelusa'

api.embedded.posts.first.attributes['title']
# => 'Linting the hell out of your Ruby classes with Pelusa'

api.embedded.posts.first.attributes.fetch('title')
# => 'Linting the hell out of your Ruby classes with Pelusa'
```

### HTTP

OK, navigating an API is really cool, but you may want to actually do something with it, right?

Hyperclient uses [Faraday](http://github.com/lostisland/faraday) under the hood to perform HTTP calls. You can call any valid HTTP method on any Resource:

```ruby
post = api._embedded.posts.first
post._get
post._head
post._put(title: 'New title')
post._patch(title: 'New title')
post._delete
post._options

posts = api._links.posts
posts._post(title: "I'm a blogger!", body: 'Wohoo!!')
```

If you have a templated link you can expand it like so:

```ruby
api._links.post._expand(id: 3).first
# => #<Resource ...>
```

You can omit the "_expand" keyword.

```ruby
api.post(id: 3).first
# => #<Resource ...>
```

You can access the Faraday connection (to add middlewares or do whatever you want) by calling `connection` on the entry point. As an example, you could use the [faraday-http-cache-middleware](https://github.com/plataformatec/faraday-http-cache):

```ruby
api.connection.use :http_cache
```

## Other

There's also a PHP library named [HyperClient](https://github.com/FoxyCart/HyperClient), if that's what you were looking for :)

## Documentation

[Hyperclient API documentation on rdoc.info](http://rubydoc.org/github/codegram/hyperclient/master/frames).

## Contributing

HyperClient is work of [many people](https://github.com/codegram/hyperclient/graphs/contributors). You're encouraged to submit [pull requests](https://github.com/codegram/hyperclient/pulls), [propose features and discuss issues](https://github.com/codegram/hyperclient/issues). See [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

MIT License, see [LICENSE](LICENSE) for details. Copyright 2012-2014 [Codegram Technologies](http://codegram.com).
