require 'test_helper'
require 'fluent/test/driver/input'

class SflowInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  PORT = 11185
  CONFIG = %[
    port #{PORT}
    bind 127.0.0.1
    tag test.sflow
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::SflowInput).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal PORT, d.instance.port
    assert_equal '127.0.0.1', d.instance.bind
    assert_equal 'test.sflow', d.instance.tag
  end
end
