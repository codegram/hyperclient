Upgrading HyperClient
=====================

### Upgrading to >= 0.5.0

#### Omit Navigational Structure

You no longer need to specify `links`, `embed` or `resource` in most cases. Just remove them.

Here're a few examples:

Instead Of                                | Write This
----------------------------------------- | -----------------------
`api._links.posts_categories`             | `api.posts_categories`
`api.links.posts.embedded.posts.first`    | `api.posts.first`
`api._links.post._expand(id: 3).first`    | `api.post(id: 3).first`

#### Change any explicit calls to `links`, `get`, `post`, etc.

Navigational methods, including `links`, `get` or `post`, have been renamed to `_link`, `_get`, or `_post` respectively. These are now systematically prefixed with underscores and otherwise treated as attributes.

For more information see [#63](https://github.com/codegram/hyperclient/pull/63).

