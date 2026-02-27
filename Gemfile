source 'https://rubygems.org'

gemspec

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
  gem 'rubocop', '~> 1.85.0', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rake', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
end

group :test do
  gem 'danger', '~> 9.5'
  gem 'danger-changelog', '~> 0.8.0'
  gem 'danger-pr-comment', '~> 0.1.0'
  gem 'danger-toc', '~> 0.2.0'
  gem 'minitest'
  gem 'mocha'
  gem 'rack-test'
  gem 'spinach'
  gem 'webmock'
end
