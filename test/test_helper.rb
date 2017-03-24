$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'

require "test/unit"
require "fluent/test"
require "fluent/plugin/in_sflow"
