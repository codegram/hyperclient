$LOAD_PATH << 'lib'

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/minitest'
require 'json'

MiniTest::Test.class_eval do
  def stub_request(conn, adapter_class = Faraday::Adapter::Test, &stubs_block)
    conn.builder.adapter adapter_class, &stubs_block
  end
end
