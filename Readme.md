# Hyperclient
[![Build Status](https://secure.travis-ci.org/codegram/hyperclient.png)](http://travis-ci.org/codegram/hyperclient)
[![Dependency Status](https://gemnasium.com/codegram/hyperclient.png)](http://gemnasium.com/codegram/hyperclient)
[![Code Climate](https://codeclimate.com/github/codegram/hyperclient.png)](https://codeclimate.com/github/codegram/hyperclient)

Hyperclient is a Ruby Hypermedia API client written in Ruby.

## Documentation

[Hyperclient API documentation on rdoc.info][rdoc]

## Usage

Example API client:

```ruby
api = Hyperclient.new('http://myapp.com/api').tap do |api|
  api.digest_auth('user', 'password')
  api.headers.merge({'accept-encoding' => 'deflate, gzip'})
end
```

By default, Hyperclient adds `application/json` as `Content-Type` and `Accept`
headers. It will also sent requests as JSON and parse JSON responses.

[More examples][examples]

## HAL

Hyperclient only works with JSON HAL friendly APIs. [Learn about JSON HAL][hal].

## Resources

Hyperclient will try to fetch and discover the resources from your API.

### Links

Accessing the links for a given resource is quite straightforward:

```ruby
api.links.posts_categories
# => #<Resource ...>
```

You can also iterate between all the links:

```ruby
api.links.each do |name, link|
  puts name, link.url
end
```

Actually, you can call any [Enumerable][enumerable] method :D

If a Resource doesn't have friendly name you can always access it as a Hash:

```ruby
api.links['http://myapi.org/rels/post_categories']
```

### Embedded resources

Accessing embedded resources is similar to accessing links:

```ruby
api.embedded.posts
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

### Attributes

Not only you might have links and embedded resources in a Resource, but also
its attributes:

```ruby
api.embedded.posts.first.attributes
# => {title: 'Linting the hell out of your Ruby classes with Pelusa',
      teaser: 'Gain new insights about your code thanks to static analysis',
      body:   '...' }
```

You can access the attribute values via attribute methods, or as a hash:

```ruby
api.embedded.posts.first.attributes.title
# => 'Linting the hell out of your Ruby classes with Pelusa'

api.embedded.posts.first.attributes['title']
# => 'Linting the hell out of your Ruby classes with Pelusa'

api.embedded.posts.first.attributes.fetch('title')
# => 'Linting the hell out of your Ruby classes with Pelusa'
```

### HTTP

OK, navigating an API is really cool, but you may want to actually do something
with it, right?

Hyperclient uses [Faraday][faraday] under the hood to perform HTTP calls. You can
call any valid HTTP method on any Resource:

```ruby
post = api.embedded.posts.first
post.get
post.head
post.put({title: 'New title'})
post.patch({title: 'New title'})
post.delete
post.options

posts = api.links.posts
posts.post({title: "I'm a blogger!", body: 'Wohoo!!'})
```

If you have a templated link you can expand it like so:

```ruby
api.links.post.expand(:id => 3).first
# => #<Resource ...>
```

You can access the Faraday connection (to add middlewares or do whatever
you want) by calling `connection` on the entry point. As an example, you could use the [faraday-http-cache-middleware](https://github.com/plataformatec/faraday-http-cache)
:

```ruby
api.connection.use :http_cache
```

## Other

There's also a PHP library named [HyperClient](https://github.com/FoxyCart/HyperClient), if that's what you were looking for :)

## TODO

* Resource permissions: Using the `Allow` header Hyperclient should be able to
  restrict the allowed method on a given `Resource`.
* Curie syntax support for links (see http://tools.ietf.org/html/draft-kelly-json-hal-03#section-8.2)
* Profile support for links


## Contributing

* [List of hyperclient contributors][contributors]

* Fork the project.
* Make your feature addition or bug fix.
* Add specs for it. This is important so we don't break it in a future
  version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  If you want to have your own version, that is fine but bump version
  in a commit by itself I can ignore when I pull.
* Send me a pull request. Bonus points for topic branches.

## License

MIT License. Copyright 2012 [Codegram Technologies][codegram]

[hal]: http://stateless.co/hal_specification.html
[contributors]: https://github.com/codegram/hyperclient/contributors
[codegram]: http://codegram.com
[documentup]: http://codegram.github.com/hyperclient
[faraday]: http://github.com/lostisland/faraday
[examples]: http://github.com/codegram/hyperclient/tree/master/examples
[enumerable]: http://ruby-doc.org/core-1.9.3/Enumerable.html
[rdoc]: http://rubydoc.org/github/codegram/hyperclient/master/frames
