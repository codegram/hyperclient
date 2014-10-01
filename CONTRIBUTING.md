Contributing to Hyperclient
===========================

Hyperclient is work of [many people](https://github.com/codegram/hyperclient/graphs/contributors). You're encouraged to submit [pull requests](https://github.com/codegram/hyperclient/pulls), [propose features and discuss issues](https://github.com/codegram/hyperclient/issues).

#### Fork the Project

Fork the [project on Github](https://github.com/codegram/hyperclient) and check out your copy.

```
git clone https://github.com/contributor/hyperclient.git
cd hyperclient
git remote add upstream https://github.com/codegram/hyperclient.git
```

#### Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

#### Bundle Install and Test

Ensure that you can build the project and run tests.

```
bundle install
bundle exec rake
```

#### Write Tests

Try to write a test that reproduces the problem you're trying to fix or describes a feature that you want to build. Add to [test/hyperclient](test/hyperclient).

We definitely appreciate pull requests that highlight or reproduce a problem, even without a fix.

#### Write Code

Implement your feature or bug fix. Don't forget to update the [README](README.md).

Ruby style is enforced with [Rubocop](https://github.com/bbatsov/rubocop), run `bundle exec rubocop` and fix any style issues highlighted.

Make sure that `bundle exec rake` completes without errors.

#### Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Writing good commit logs is important. A commit log should describe what changed and why.

```
git add ...
git commit
```

#### Push

```
git push origin my-feature-branch
```

#### Make a Pull Request

Go to https://github.com/contributor/hyperclient and select your feature branch. Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

#### Update CHANGELOG

Update the [CHANGELOG](CHANGELOG.md) with the pull request number. A typical entry looks as follows.

```
* [#123](https://github.com/codegram/hyperclient/pull/123): Reticulated splines - [@contributor](https://github.com/contributor).
```

We like neat commits. Amend your previous commit and force push the changes.

```
git commit --amend
git push origin my-feature-branch -f
```

#### Rebase

If you've been working on a change for a while, rebase with upstream/master often.

```
git fetch upstream
git rebase upstream/master
git push origin my-feature-branch -f
```

We like neat commits, please try to amend your previous commits and force push the changes.

```
git commit --amend
git push origin my-feature-branch -f
```

#### Check on Your Pull Request

Go back to your pull request after a few minutes and see whether it passed muster with Travis-CI. Everything should look green, otherwise fix issues and amend your commit as described above.

#### Be Patient

It's likely that your change will not be merged and that the nitpicky maintainers will ask you to do more, or fix seemingly benign problems. Hang on there!

#### Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
