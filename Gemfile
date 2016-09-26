source 'https://rubygems.org'

gemspec

group :development do
  gem 'growl'
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-spinach'
  gem 'pry'
end

group :development, :test do
  gem 'yard', '~> 0.8'
  gem 'yard-tomdoc'
  gem 'rake'
  gem 'simplecov', require: false
  gem 'rubocop', '~> 0.42.0', require: false
end

group :test do
  gem 'futuroscope', github: 'codegram/futuroscope'
  gem 'danger-changelog', '~> 0.1'
  gem 'minitest'
  gem 'turn'
  gem 'webmock'
  gem 'mocha'
  gem 'rack-test'
  gem 'spinach'
end
