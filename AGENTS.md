# Agent Guide

Hyperclient is a Ruby client for JSON HAL APIs, built on Faraday 2 and `faraday_hal_middleware`.

## Layout

- `lib/hyperclient.rb`: client entry point and configuration.
- `lib/hyperclient/`: resources, links, collections, attributes, and CURIEs.
- `test/`: Minitest tests and fixtures.
- `features/`: Spinach acceptance tests and supporting code.
- `examples/`: runnable usage examples.

## Commands

```sh
bundle install
bundle exec rake                 # Minitest, Spinach, and RuboCop
bundle exec rake test            # Minitest only
bundle exec rake spinach         # Acceptance tests only
bundle exec rake rubocop         # Lint
bundle exec ruby -Itest test/hyperclient_test.rb
```

## Changes

Follow existing Ruby conventions and preserve Ruby 2.7 compatibility. Add regression tests for behavior changes; use existing HTTP stubs rather than depending on external services. Update the README for public API changes and the changelog with the pull request number. See `CONTRIBUTING.md` for the full contribution workflow and `.github/workflows/` for the CI matrix.
