source 'https://rubygems.org'

gem 'faraday', ENV['FARADAY_VERSION'] if ENV['FARADAY_VERSION'] && !ENV['FARADAY_VERSION'].empty?

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
  gem 'rubocop', '~> 1.50.2', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rake', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
end

group :test do
  gem 'danger-changelog', '~> 0.6.0'
  gem 'danger-toc', '~> 0.2.0'
  gem 'minitest'
  gem 'mocha'
  gem 'rack-test'
  gem 'spinach'
  gem 'webmock'
end
