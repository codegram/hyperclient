# NOTE: this is temporary until Bundler 2.0 changes how github: references work.
git_source(:github) { |repo| "https://github.com/#{repo['/'] ? repo : "#{repo}/#{repo}"}.git" }

source 'https://rubygems.org'

gem 'faraday', ENV['FARADAY_VERSION'] if ENV.key?('FARADAY_VERSION')

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
  gem 'rubocop', '1.41.1', require: false
  gem 'simplecov', require: false
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
