source 'https://rubygems.org'

gemspec

gem 'json', "~> #{ENV['JSON_VERSION']}.0" if ENV['JSON_VERSION']

group :development do
  gem 'growl'
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-spinach'
  gem 'pry'
  gem 'pry-byebug', platforms: :ruby
end

group :development, :test do
  gem 'rake'
  gem 'rubocop', '~> 1.92.0', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rake', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'webrick', '~> 1.8'
end

group :test do
  gem 'minitest'
  gem 'mocha'
  gem 'rack-test'
  gem 'spinach'
  gem 'webmock'
end

# Danger runs separately on Ruby 4.0; its plugins require Ruby 3.1+.
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.1')
  group :danger do
    gem 'danger', '~> 9.5'
    gem 'danger-changelog', '~> 0.10.0'
    gem 'danger-pr-comment', '~> 0.1.0'
    gem 'danger-toc', '~> 0.3.0'
  end
end
