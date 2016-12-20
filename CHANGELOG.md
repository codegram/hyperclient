### 0.8.2 (Next)

This version is no longer tested with Ruby < 2.2.

* [#105](https://github.com/codegram/hyperclient/pull/105), [#108](https://github.com/codegram/hyperclient/pull/108): Added Danger, PR linter - [@dblock](https://github.com/dblock).
* [#109](https://github.com/codegram/hyperclient/pull/109): Allow disabling asynchronous behavior per-instance - [@Talkdesk](https://github.com/Talkdesk/).
* Your contribution here.

### 0.8.1 (March 15, 2016)

* [#97](https://github.com/codegram/hyperclient/issues/97): Fix: curies are no longer used as link shorteners - [@joshco](https://github.com/joshco), [@dblock](https://github.com/dblock).
* [#95](https://github.com/codegram/hyperclient/issues/95): Fix: re-add eager delegation for `resource.each` - [@dblock](https://github.com/dblock).

### 0.7.2 (August 23, 2015)

* [#95](https://github.com/codegram/hyperclient/issues/95): Fix: re-add eager delegation for `resource.x._embeddded.x` - [@dblock](https://github.com/dblock).

### 0.7.1 (August 15, 2015)

* [#89](https://github.com/codegram/hyperclient/issues/89): Added `Hyperclient::Resource#fetch` - [@alabeduarte](https://github.com/alabeduarte).
* [#87](https://github.com/codegram/hyperclient/pull/87): Fix: eager delegation causes link skipping - [@dblock](https://github.com/dblock).

### 0.7.0 (February 23, 2015)

This version introduces several backwards incompatible changes. See [UPGRADING](UPGRADING.md) for details.

* [#80](https://github.com/codegram/hyperclient/pull/80): Faraday options can be passed to the connection on initialization - [@koenpunt](https://github.com/koenpunt).
* [#81](https://github.com/codegram/hyperclient/pull/81): The default Content-Type is now `application/hal+json` - [@koenpunt](https://github.com/koenpunt).

### 0.6.1 (October 17, 2014)

This version introduces several backwards incompatible changes. See [UPGRADING](UPGRADING.md) for details.

* [#51](https://github.com/codegram/hyperclient/issues/51), [#75](https://github.com/codegram/hyperclient/pull/75): Added support for setting headers and overriding or extending the default Faraday connection block before a connection is constructed - [@dblock](https://github.com/dblock).
* [#41](https://github.com/codegram/hyperclient/issues/41), [#73](https://github.com/codegram/hyperclient/pull/73): All Link HTTP methods now return a Resource, including `_get`, which has been aliased to `_resource`, `_post`, `_put`, `_patch`, `_head` and `_options` - [@dblock](https://github.com/dblock).
* [#72](https://github.com/codegram/hyperclient/pull/72): The default Faraday block now uses `Faraday::Response::RaiseError` and will cause HTTP errors to be raised as exceptions - [@dblock](https://github.com/dblock).
* [#77](https://github.com/codegram/hyperclient/pull/77): Added support for templated links with all optional arguments - [@dblock](https://github.com/dblock).

### 0.5.0 (October 1, 2014)

This version introduces several backwards incompatible changes. See [UPGRADING](UPGRADING.md) for details.

* [#63](https://github.com/codegram/hyperclient/pull/63): Navigational methods, including `links`, `get` or `post`, have been renamed to `_links`, `_get`, or `_post` respectively - [@dblock](https://github.com/dblock).
* [#64](https://github.com/codegram/hyperclient/issues/64): Added support for curies - [@dblock](https://github.com/dblock).
* [#58](https://github.com/codegram/hyperclient/issues/58): Automatically follow redirects - [@dblock](https://github.com/dblock).
* [#63](https://github.com/codegram/hyperclient/pull/63): You can omit the navigational elements, `api.links.products` is now equivalent to `api.products` - [@dblock](https://github.com/dblock).
* [#61](https://github.com/codegram/hyperclient/pull/61): Implemented Rubocop, Ruby-style linter - [@dblock](https://github.com/dblock).

### 0.4.0 (May 5, 2014)

* [#54](https://github.com/codegram/hyperclient/pull/54): Support Faraday 0.9.0 - [@lucianapazos](https://github.com/lucianapazos).
* [#30](https://github.com/codegram/hyperclient/pull/30): Use futuroscope to run API calls in the background - [@josepjaume](https://github.com/josepjaume).

### 0.3.2 (December 20, 2013)

* [#48](https://github.com/codegram/hyperclient/pull/48): Added support for fetch on the collection class - [@col](https://github.com/col).
* [#50](https://github.com/codegram/hyperclient/pull/50): Fixed Resource/Attributes mutating the response body - [@col](https://github.com/col).
* [#46](https://github.com/codegram/hyperclient/pull/46): Made response available inside Resource, provide access to status codes - [@benhamill](https://github.com/benhamill).
* [#43](https://github.com/codegram/hyperclient/pull/43): Fixed LinkCollection#include? - [@benhamill](https://github.com/benhamill).
* [#47](https://github.com/codegram/hyperclient/pull/47): Fixed uninitialized constant Hyperclient::Resource::Forwardable - [@benhamill](https://github.com/benhamill).
* [#39](https://github.com/codegram/hyperclient/pull/39): Exposed templated link properties - [@txus](https://github.com/txus).
* [#38](https://github.com/codegram/hyperclient/pull/38): Defaulted POST, PUT and PATCH parameters - [@bkeepers](https://github.com/bkeepers).
* [#37](https://github.com/codegram/hyperclient/pull/37): Fixed calling #flatten on an array of links - [@bkeepers](https://github.com/bkeepers).
* [#36](https://github.com/codegram/hyperclient/pull/36): Exposed link properties - [@bkeepers](https://github.com/bkeepers).
* [#31](https://github.com/codegram/hyperclient/pull/31): Allowed underscored attribute names other than the ones reserved by the HAL spec - [@karlin](https://github.com/karlin).
* [#29](https://github.com/codegram/hyperclient/pull/29): Handled JSON that includes a link with a null value - [@arbylee](https://github.com/arbylee).

### 0.3.1 (April 3, 2013)

* [#27](https://github.com/codegram/hyperclient/pull/27): Added support for collections of links - [@rehevkor5](https://github.com/rehevkor5).

### 0.3.0 (February 3, 2013)

* Initial public release - [@oriolgual](https://github.com/oriolgual).
