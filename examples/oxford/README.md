# Local Oxford HAL Demo

This read-only demo uses a small selection of public place facts from Oxford's retired mobile API. It runs entirely on localhost; neither Oxford nor the Internet Archive is contacted when running the example. The information is historical, not a current directory.

From the repository root, install dependencies and start the server:

```sh
bundle install
bundle exec ruby examples/oxford/server.rb
```

In a second terminal:

```sh
bundle exec ruby -Ilib examples/oxford/client.rb
```

The server binds only to `127.0.0.1:9292`. Set `PORT` on the server and `OXFORD_URL` on the client to use another port. Stop the server with Ctrl-C.

The client demonstrates collection traversal, attributes, a templated place link, following `primary_place`, embedded file metadata, and CURIE expansion. It prints image URLs without downloading images. Unknown paths return 404; writes return 405.

## Provenance and Adaptations

The factual fields and original place path in `places.json` were transcribed from [Balliol College's archived response, September 10, 2020](https://web.archive.org/web/20200910141343id_/https://api.m.ox.ac.uk/places/oxpoints:23232339). The record retains the original ID, name, address, coordinates, self/primary-place paths, and one image URL. No image or descriptive prose is redistributed.

The [archived API root, July 12, 2024](https://web.archive.org/web/20240712050404id_/http://api.m.ox.ac.uk/) demonstrates the original HAL-style links. See also [Moxie's OxPoints importer documentation](https://moxie.readthedocs.io/en/latest/places/oxpoints.html).

## Data License

The underlying OxPoints place data is dedicated to the public domain under [CC0](https://creativecommons.org/publicdomain/zero/1.0/). Oxford's own presentation, [*OxPoints and data.ox.ac.uk*, Alexander Dutton, InfoDev, OUCS (2011)](https://old.ictf.ox.ac.uk/conference/2011/presentations/wks11_oxpoints_dataox.pdf), identifies names, coordinates, addresses, and identifiers as OxPoints data (slides 2-5) and explicitly states "Public domain (CC0; no attribution required)" (slide 8). The place facts in `places.json` come from this dataset via the archived mobile API response cited above; the HAL wrappers and local links are demo adaptations.

This is not a license claim for full archived API responses or photographs. The depiction URL is retained only as a reference to an external image; the image itself is not included, fetched, or covered by this notice. Newly authored server code and documentation are under this project's license. Moxie's Apache-2.0 code license is separate from the OxPoints data license.

The root, collection wrapper, templated `place` link, `oxford` CURIE, and local relation documentation are demo additions, not a reconstruction of the original service. Responses use `application/hal+json`; the archived service returned `application/json`. Relative place links retain their original paths and resolve locally. Unavailable child links, images, and unrelated API endpoints are not mirrored.

## Tests

```sh
bundle exec ruby -Itest test/oxford_example_test.rb
```

The tests exercise the same app and client using local HTTP stubs, without requiring a running server or external network access. They are also included in `bundle exec rake test`.
