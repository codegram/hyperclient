Upgrading Hyperclient
=====================

### Upgrading to Next

#### Changes in HTTP Error Handling

The default Faraday block now uses `Faraday::Response::RaiseError` and will cause HTTP errors to be raised as exceptions. Older versions of Hyperclient swallowed the error and returned an empty resource. If you relied on checking for an HTTP response `status`, rescue `Faraday::ClientError`.

#### Changes in Values Returned from HTTP Methods

The `Link#_get` method has been aliased to `_resource`. All HTTP methods, including `_post`, `_put`, `_delete`, `_patch`, `_options` and `_head` now return instances of Resource. Older versions returned a `Faraday::Response`.

### Upgrading to >= 0.5.0

#### Remove Navigational Elements

You can, but no longer need to invoke `links`, `embedded`, `expand`, `attributes` or `resource` in most cases. Simply remove them. Navigational structures like `key.embedded.key` can also be collapsed.

Here're a few examples:

Instead Of                                      | Write This
----------------------------------------------- | -----------------------
`api.links.widgets`                             | `api.widgets`
`api.links.widgets.embedded.widgets.first`      | `api.widgets.first`
`api.links.widgets.embedded.comments`           | `api.widgets.comments`
`api.links.widget.expand(id: 3)`                | `api.widget(id: 3)`
`api.links.widget.expand(id: 3).resource.id`    | `api.widget(id: 3).id`

If you prefer to specify the complete HAL navigational structure, you must rename the methods to their new underscore equivalents. See below.

#### Change Naviational Elements and HTTP Verbs to Underscore Versions

Navigational methods and HTTP verbs have been renamed to their underscore versions and are otherwise treated as attributes.

Instead Of                                              | Write This
------------------------------------------------------- | ----------------------------------------------------------------
`api.links`                                             | `api._links`
`api.links.widgets.embedded.widgets.first`              | `api._links.widgets._embedded.first`
`api.links.widget.expand(id: 3).resource`               | `api._links.widget._expand(id: 3)._resource`
`api.get`                                               | `api._get`
`api.links.widgets.widget(id: 3).delete`                | `api._links.widget._expand(id: 3)._delete`
`api.links.widgets.post(name: 'a widget')`              | `api._links.widgets._post(name: 'a widget')
`api.links.widget.expand(id: 3).put(name: 'updated`)    | `api._links.widget._expand(id: 3)._put(name: 'updated')`

For more information see [#63](https://github.com/codegram/hyperclient/pull/63).

