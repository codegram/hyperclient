# Hyperclient 
[![Build Status](https://secure.travis-ci.org/codegram/hyperclient.png)](http://travis-ci.org/codegram/hyperclient) 
[![Dependency Status](https://gemnasium.com/codegram/hyperclient.png)](http://gemnasium.com/codegram/hyperclient)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/codegram/hyperclient)

Hyperclient is a Ruby Hypermedia API client written in Ruby.

## Documentation

[Hyperclient API documentation on rdoc.info][rdoc]

## Usage

Example API client:

````ruby
class MyAPIClient
  include Hyperclient

  entry_point{'http://myapp.com/api'}
  auth{ {type: :digest, user: 'user', password: 'secret'} }
  http_options headers: {'accept-encoding' => 'deflate, gzip'}, debug: true
end
````

[More examples][examples]

## HAL

Hyperclient only works with JSON HAL friendly APIs. [Learn about JSON HAL][hal].

## Resources

Hyperclient will try to fetch and discover the resources from your API. 

### Links

Accessing the links for a given resource is quite straightforward:

````ruby
api = MyAPIClient.new
api.links.posts_categories
# => #<Resource @name="posts_categories" ...>
````

You can also iterate between all the links:

````ruby
api.links.each do |link|
  puts link.name, link.url
end
````

Actually, you can call any [Enumerable][enumerable] method :D

If a Resource doesn't have friendly name you can always access it as a Hash:

````ruby
api = MyAPIClient.new
api.links['http://myapi.org/rels/post_categories']
````

### Embedded resources

Accessing embedded resources is similar to accessing links:

````ruby
api = MyAPIClient.new
api.resources.posts
# => #<Resource @name="posts" ...>
````

And you can also iterate between them:

````ruby
api.resources.each do |resource|
  puts resource.name, resource.url
end
````

You can even chain different calls (this also applies for links):

````ruby
api.resources.posts.first.links.author
# => #<Resource @name="author" ...>
````

### Attributes

Not only you might have links and embedded resources in a Resource, but also
its attributes:

````ruby
api.resources.posts.first.attributes
# => {title: 'Linting the hell out of your Ruby classes with Pelusa',
      teaser: 'Gain new insights about your code thanks to static analysis',
      body:   '...' }
````

### HTTP

OK, navigating an API is really cool, but you may want to actually do something
with it, right?

Hyperclient uses [HTTParty][httparty] under the hood to perform HTTP calls. You can
call any valid HTTP method on any Resource:

````ruby
post = api.resources.posts.first
post.get
post.head
post.put({title: 'New title'})
post.delete
post.options

posts = api.resources.posts
posts.post({title: "I'm a blogger!", body: 'Wohoo!!'})
````

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
[httparty]: http://github.com/jnunemaker/httparty
[examples]: http://github.com/codegram/hyperclient/tree/master/examples
[enumerable]: http://ruby-doc.org/core-1.9.3/Enumerable.html
[rdoc]: http://rubydoc.org/github/codegram/hyperclient/master/frames