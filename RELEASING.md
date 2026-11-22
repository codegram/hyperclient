# Releasing Hyperclient

Release bug fixes frequently, features less frequently, and breaking API changes rarely.

Releases run through the [Release workflow](.github/workflows/release.yml), which uses [ruby-gem-release](https://github.com/dblock/ruby-gem-release/tree/v0.9.0) and RubyGems Trusted Publishing. Merging does not publish anything, and the local Bundler `rake release` task is disabled.

## One-Time Setup

Create a GitHub environment named `release` in this repository, for example with `gh api --method PUT repos/codegram/hyperclient/environments/release`. To require a maintainer's approval before publication, add required reviewers and restrict deployment to `master`.

On RubyGems, open the [hyperclient trusted publishers](https://rubygems.org/gems/hyperclient/trusted_publishers) page and add a GitHub Actions publisher with repository owner `codegram`, repository name `hyperclient`, workflow filename `release.yml`, and environment `release`. Set the separate workflow repository owner to `dblock` and name to `ruby-gem-release`, because publication runs in that reusable workflow. No RubyGems API key is stored.

The workflow needs to push the release commit, the `vVERSION` tag, and the next development commit to `master`. Branch and tag rules must allow that; every release checks them before publishing.

## Prepare the Release

Releases publish the version in [lib/hyperclient/version.rb](lib/hyperclient/version.rb) with the notes in its `### VERSION (Next)` section of [CHANGELOG.md](CHANGELOG.md). Use a patch version for backward-compatible fixes, a minor version for backward-compatible features, and a major version for breaking changes. To change it, update both files in a pull request, or pass a different version when starting the release.

Check that CI has succeeded on `master`, and don't merge anything while a release is running.

## Release

Check the setup without releasing anything:

```sh
gh workflow run release.yml --repo codegram/hyperclient --ref master -f dry-run=true
```

Then release the checked-in version:

```sh
gh workflow run release.yml --repo codegram/hyperclient --ref master
```

To release a different version, pass `-f version=2.3.0`.

The workflow runs `bundle exec rake` on Ruby 4.0 with [gemfiles/release.gemfile](gemfiles/release.gemfile), dates the changelog section and removes its "Your contribution here." placeholder, publishes the gem to RubyGems, pushes the release commit and tag, and creates a GitHub Release with the changelog notes. It then increments the patch version and pushes a new `### VERSION (Next)` section to `master`.

## Verify and Recover

Check the RubyGems version, the matching tag and GitHub Release, and the next development version on `master`:

```sh
version=2.2.0
curl --fail --silent --show-error "https://rubygems.org/api/v2/rubygems/hyperclient/versions/$version.json"
gh release view "v$version" --repo codegram/hyperclient
```

Don't rerun a failed release blindly: RubyGems may have accepted the gem. Inspect the existing tag, RubyGems version, and GitHub Release first, and never republish a version or move its tag. Follow the [ruby-gem-release recovery instructions](https://github.com/dblock/ruby-gem-release/blob/v0.9.0/docs/actions/release.md#recovery-artifacts) to complete only the missing steps.

## Run the Release Tasks Locally

The release tasks need Ruby 3.3+ and the release bundle:

```sh
BUNDLE_GEMFILE=gemfiles/release.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/release.gemfile bundle exec rake -T release
```
