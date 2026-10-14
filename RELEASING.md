# Releasing Hyperclient

Release bug fixes frequently, features less frequently, and breaking API changes rarely.

## Prepare the Release

Start with a clean, up-to-date `master` branch. Check that CI has succeeded for all supported platforms.

Set the release version in [lib/hyperclient/version.rb](lib/hyperclient/version.rb). Use a patch version for backward-compatible fixes, a minor version for backward-compatible features, and a major version for breaking changes.

Replace the next-version heading in [CHANGELOG.md](CHANGELOG.md) with the release version and date, for example `### 2.1.0 (2026/10/14)`. Remove the "Your contribution here." placeholder from that release.

Run the full suite, then commit and push the release preparation:

```sh
bundle install
bundle exec rake
git add CHANGELOG.md lib/hyperclient/version.rb
git commit -m "Preparing for release, 2.1.0."
git push origin master
```

Wait for CI on the release preparation commit to succeed before publishing.

## Publish to RubyGems and GitHub

Publish the gem using Bundler's release task. This builds the gem, creates and pushes the version tag, and publishes to RubyGems. Complete RubyGems MFA when prompted.

```sh
bundle exec rake release
```

Creating a Git tag does **not** create a GitHub release. After confirming that the gem was published successfully, create a GitHub release for the same tag. Put the matching changelog section's entries in a temporary file and use them as the release notes:

```sh
version=2.1.0
notes="$(mktemp)"
awk -v version="$version" '
  /^### / {
    if (found) exit
    if ($2 == version) found = 1
    next
  }
  found { print }
' CHANGELOG.md > "$notes"
gh release create "v$version" --repo codegram/hyperclient --verify-tag --title "$version" --notes-file "$notes" --latest
rm "$notes"
```

Verify both publications before considering the release complete:

```sh
curl --fail --silent --show-error "https://rubygems.org/api/v2/rubygems/hyperclient/versions/$version.json"
gh release view "v$version" --repo codegram/hyperclient
```

If publishing is interrupted, inspect the existing tag, RubyGems version, and GitHub release first. Resume only the missing step; do not move or recreate a published tag.

## Prepare the Next Version

Increment the development patch version in [lib/hyperclient/version.rb](lib/hyperclient/version.rb), for example from `2.1.0` to `2.1.1`. Add the matching unreleased section at the top of [CHANGELOG.md](CHANGELOG.md):

```markdown
### 2.1.1 (Next)

* Your contribution here.
```

Commit and push:

```sh
git add CHANGELOG.md lib/hyperclient/version.rb
git commit -m "Preparing for next release, 2.1.1."
git push origin master
```
