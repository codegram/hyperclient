$LOAD_PATH << 'lib'

if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-lcov'
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.lcov_file_name = 'lcov.info'
    c.single_report_path = 'coverage/lcov.info'
  end
  SimpleCov.start do
    add_filter '/test/'
    add_filter '/features/'
  end
end

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/minitest'
require 'json'

require 'faraday'
require 'faraday/request/instrumentation'

Minitest::Assertions.class_eval do
  def stub_request(conn, adapter_class = Faraday::Adapter::Test, &stubs_block)
    adapter_handler = conn.builder.handlers.find { |h| h.klass < Faraday::Adapter }
    if adapter_handler
      conn.builder.swap(adapter_handler, adapter_class, &stubs_block)
    else
      conn.builder.adapter adapter_class, &stubs_block
    end
  end
end
