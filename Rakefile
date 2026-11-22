#!/usr/bin/env rake

require 'rubygems'
require 'bundler'
Bundler.setup :default, :test, :development

Bundler::GemHelper.install_tasks

# Releases run through the Release workflow, see RELEASING.md.
%w[release release:rubygem_push release:source_control_push].each do |name|
  Rake::Task[name].clear
  desc 'Disabled, releases run through the Release workflow (see RELEASING.md)'
  task(name) { abort "#{name} is disabled; releases run through GitHub Actions, see RELEASING.md" }
end

# The release tasks are only installed with BUNDLE_GEMFILE=gemfiles/release.gemfile.
if Gem.loaded_specs.key?('ruby-gem-release')
  require 'ruby-gem-release/workflow/ruby_gem'
  require 'ruby-gem-release/changelog'

  RubyGemRelease::Workflow::RubyGem.new(
    version: RubyGemRelease::Version::RubyConstant.new(path: 'lib/hyperclient/version.rb', constant: 'VERSION'),
    changelog: RubyGemRelease::Changelog::Intridea.new(placeholder: '* Your contribution here.')
  ).install_tasks
end

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
  t.warning = true
end

desc 'runs the whole spinach suite'
task :spinach do
  ruby '-S spinach'
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task default: %i[test spinach rubocop]
