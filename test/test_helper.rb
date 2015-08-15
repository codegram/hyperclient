$LOAD_PATH << 'lib'
gem 'minitest'

require 'minitest/spec'
require 'minitest/autorun'
require 'mocha/setup'
require 'turn'
require 'json'
require 'pry'

MiniTest::Unit::TestCase.class_eval do
  def stub_request(conn, adapter_class = Faraday::Adapter::Test, &stubs_block)
    adapter_handler = conn.builder.handlers.find { |h| h.klass < Faraday::Adapter }
    conn.builder.swap(adapter_handler, adapter_class, &stubs_block)
  end
end
