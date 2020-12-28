## Changelog

### 1.0.0 (Next)

* [#193](https://github.com/codegram/hyperclient/pull/193): Auto-paginate collections - [@dblock](https://github.com/dblock).
* [#163](https://github.com/codegram/hyperclient/pull/163): Test against Faraday 0.9, 0.17 and 1.0+ - [@dblock](https://github.com/dblock).
* Your contribution here.

### 0.9.3 (2020/05/14)

* [#149](https://github.com/codegram/hyperclient/pull/149): Address Faraday warnings - [@yuki24](https://github.com/yuki24).
* [#160](https://github.com/codegram/hyperclient/pull/160): Require newer 'faraday-digestauth' - [@dblock](https://github.com/dblock).

### 0.9.2 (2020/05/12)

* NOTE: **⚠ This version has been yanked ⚠** - [@dblock](https://github.com/dblock).

### 0.9.1 (2019/08/25)

* NOTE: **⚠ This version is no longer tested with Ruby < 2.3 ⚠** - [@ivoanjo](https://github.com/ivoanjo).

* [#135](https://github.com/codegram/hyperclient/pull/135): Fix validation for empty body responses - [@paulocdf](https://github.com/paulocdf).
* [#139](https://github.com/codegram/hyperclient/pull/139): Test `hyperclient` against newer versions of MRI Ruby, up until 2.6.x - [@mrcasals](https://github.com/mrcasals).
* [#141](https://github.com/codegram/hyperclient/pull/141): Replace `uri_template` with `addressable` library - [@mrcasals](https://github.com/mrcasals).
* [#136](https://github.com/codegram/hyperclient/pull/136), [#146](https://github.com/codegram/hyperclient/pull/146): Upgraded Danger plugins - [@dblock](https://github.com/dblock), [@ivoanjo](https://github.com/ivoanjo).

### 0.9.0 (2018/01/10)

* [#133](https://github.com/codegram/hyperclient/pull/133): Removed futuroscope - [@dblock](https://github.com/dblock).
* [#131](https://github.com/codegram/hyperclient/pull/131): Upgrade to Rubocop 0.50.0, fix Bundler's insecure git source warning - [@nebolsin](https://github.com/nebolsin).
* [#132](https://github.com/codegram/hyperclient/pull/132): Swapped yard dependency for danger-toc - [@dblock](https://github.com/dblock).

### 0.8.6 (2017/08/27)

* [#122](https://github.com/codegram/hyperclient/pull/122): Improve error message when server returns invalid data - [@ivoanjo](https://github.com/ivoanjo).
* [#125](https://github.com/codegram/hyperclient/pull/125): Add table of contents to readme and add note asking users to add their projects to the wiki - [@ivoanjo](https://github.com/ivoanjo).
* [#127](https://github.com/codegram/hyperclient/pull/127): Minor fixes: Fix warnings, and pry-byebug to dev Gemfile and tweak rubocop execution - [@ivoanjo](https://github.com/ivoanjo).
* [#128](https://github.com/codegram/hyperclient/pull/128): Fix link delegation returning nil for field with value false - [@ivoanjo](https://github.com/ivoanjo).

### 0.8.5 (2017/07/05)

* [#120](https://github.com/codegram/hyperclient/pull/120): Replace non-working homepage link in gemspec - [@ivoanjo](https://github.com/ivoanjo).

### 0.8.4 (2017/05/16)

* [#117](https://github.com/codegram/hyperclient/issues/117): Require Faraday >= 0.9.0 in gemspec - [@ivoanjo](https://github.com/ivoanjo).

### 0.8.3 (2017/03/30)

* [#115](https://github.com/codegram/hyperclient/pull/115): Fix dropped values from queries by using FlatParamsEncoder - [@ivoanjo](https://github.com/ivoanjo).

### 0.8.2 (2016/12/31)

* NOTE: **⚠ This version is no longer tested with Ruby < 2.2 ⚠** - [@dblock](https://github.com/dblock).

* [#105](https://github.com/codegram/hyperclient/pull/105), [#108](https://github.com/codegram/hyperclient/pull/108): Added Danger, PR linter - [@dblock](https://github.com/dblock).
* [#109](https://github.com/codegram/hyperclient/pull/109): Allow disabling asynchronous behavior per-instance - [@Talkdesk](https://github.com/Talkdesk).
* [#110](https://github.com/codegram/hyperclient/pull/110): Fixed ruby warnings - [@ivoanjo](https://github.com/ivoanjo).

### 0.8.1 (2016/03/15)

* [#97](https://github.com/codegram/hyperclient/issues/97): Fix: curies are no longer used as link shorteners - [@joshco](https://github.com/joshco), [@dblock](https://github.com/dblock).
* [#95](https://github.com/codegram/hyperclient/issues/95): Fix: re-add eager delegation for `resource.each` - [@dblock](https://github.com/dblock).

### 0.7.2 (2015/08/23)

* [#95](https://github.com/codegram/hyperclient/issues/95): Fix: re-add eager delegation for `resource.x._embeddded.x` - [@dblock](https://github.com/dblock).

### 0.7.1 (2015/08/15)

* [#89](https://github.com/codegram/hyperclient/issues/89): Added `Hyperclient::Resource#fetch` - [@alabeduarte](https://github.com/alabeduarte).
* [#87](https://github.com/codegram/hyperclient/pull/87): Fix: eager delegation causes link skipping - [@dblock](https://github.com/dblock).

### 0.7.0 (2015/02/23)

* NOTE: **⚠ This version introduces several backwards incompatible changes. See [UPGRADING](UPGRADING.md) for details ⚠** - [@dblock](https://github.com/dblock).

* [#80](https://github.com/codegram/hyperclient/pull/80): Faraday options can be passed to the connection on initialization - [@koenpunt](https://github.com/koenpunt).
* [#81](https://github.com/codegram/hyperclient/pull/81): The default Content-Type is now `application/hal+json` - [@koenpunt](https://github.com/koenpunt).

### 0.6.1 (2014/10/17)

* NOTE: **⚠ This version introduces several backwards incompatible changes. See [UPGRADING](UPGRADING.md) for details ⚠** - [@dblock](https://github.com/dblock).

* [#51](https://github.com/codegram/hyperclient/issues/51), [#75](https://github.com/codegram/hyperclient/pull/75): Added support for setting headers and overriding or extending the default Faraday connection block before a connection is constructed - [@dblock](https://github.com/dblock).
* [#41](https://github.com/codegram/hyperclient/issues/41), [#73](https://github.com/codegram/hyperclient/pull/73): All Link HTTP methods now return a Resource, including `_get`, which has been aliased to `_resource`, `_post`, `_put`, `_patch`, `_head` and `_options` - [@dblock](https://github.com/dblock).
* [#72](https://github.com/codegram/hyperclient/pull/72): The default Faraday block now uses `Faraday::Response::RaiseError` and will cause HTTP errors to be raised as exceptions - [@dblock](https://github.com/dblock).
* [#77](https://github.com/codegram/hyperclient/pull/77): Added support for templated links with all optional arguments - [@dblock](https://github.com/dblock).

### 0.5.0 (2014/10/01)

* NOTE: **⚠ This version introduces several backwards incompatible changes. See [UPGRADING](UPGRADING.md) for details ⚠** - [@dblock](https://github.com/dblock).

* [#63](https://github.com/codegram/hyperclient/pull/63): Navigational methods, including `links`, `get` or `post`, have been renamed to `_links`, `_get`, or `_post` respectively - [@dblock](https://github.com/dblock).
* [#64](https://github.com/codegram/hyperclient/issues/64): Added support for curies - [@dblock](https://github.com/dblock).
* [#58](https://github.com/codegram/hyperclient/issues/58): Automatically follow redirects - [@dblock](https://github.com/dblock).
* [#63](https://github.com/codegram/hyperclient/pull/63): You can omit the navigational elements, `api.links.products` is now equivalent to `api.products` - [@dblock](https://github.com/dblock).
* [#61](https://github.com/codegram/hyperclient/pull/61): Implemented Rubocop, Ruby-style linter - [@dblock](https://github.com/dblock).

### 0.4.0 (2014/05/05)

* [#54](https://github.com/codegram/hyperclient/pull/54): Support Faraday 0.9.0 - [@lucianapazos](https://github.com/lucianapazos).
* [#30](https://github.com/codegram/hyperclient/pull/30): Use futuroscope to run API calls in the background - [@josepjaume](https://github.com/josepjaume).

### 0.3.2 (2013/12/20)

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

### 0.3.1 (2013/04/03)

* [#27](https://github.com/codegram/hyperclient/pull/27): Added support for collections of links - [@rehevkor5](https://github.com/rehevkor5).

### 0.3.0 (2013/02/03)

* Initial public release - [@oriolgual](https://github.com/oriolgual).
