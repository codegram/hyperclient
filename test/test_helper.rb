if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

gem 'minitest'

require 'minitest/spec'
require 'minitest/autorun'
require 'mocha'
require 'turn'
require 'webmock/minitest'
require 'json'
require 'pry'