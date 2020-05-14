$LOAD_PATH << 'lib'

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/minitest'
require 'json'

MiniTest::Test.class_eval do
  def stub_request(conn, adapter_class = Faraday::Adapter::Test, &stubs_block)
    adapter_handler = conn.builder.handlers.find { |h| h.klass < Faraday::Adapter }
    if adapter_handler
      conn.builder.swap(adapter_handler, adapter_class, &stubs_block)
    else
      conn.builder.adapter adapter_class, &stubs_block
    end
  end
end
