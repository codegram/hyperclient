# Read last HAL draft first: http://tools.ietf.org/html/draft-kelly-json-hal-03

api = MyBlogAPI.new

# Entry point
api.links => [link1, link2, link3]
api.links.self.url => '/'
api.embedded => []

# Links
api.links.posts => <#Link @relation="posts">
api.links.posts.templated? => false

# Templated links
api.links.search.templated? => true
api.links.search.resource => MissingURITemplateVariablesException raised

search_results = api.links.search.resource(q: 'some text') => <#Resource @name="search">
search_results.links.self.url => '/search?q=some+text'

# Embedded resources
search_results.embedded => [post1, post2, post3]

# Accessing a resource from a link
post = api.links.posts.resource => <#Resource @name="posts">

# At this point the resource hasn't be loaded: we haven't sent a GET request to
# '/posts/'. Any interaction with the resource (links, properties or embedded
# resources) will trigger the loading.
#
# Alternatevly, we can do this to load the resource:
post.reload

# Example links
post.links.author => <#Link @relation="author">

# Resource properties
post.properties.title => 'Awesome post'
post.properties['body'] => 'Lorem ipsum dolor sit smet'

# Alternate version I'm not sure about
post.body => 'Lorem ipsum dolor sit amet'

# From the last draft, links are optional (http://tools.ietf.org/html/draft-kelly-json-hal-03#section-4.1.1
post.embedded.comments.first.links => []

# HTTP methods can be called either on links (to prevent loading the actual
# resource) or on resources (will be delegated to the self link, actually).
post.links.comments.post(text: 'HATEOAS FTW')
post.put(title: 'Even moar awesome')
