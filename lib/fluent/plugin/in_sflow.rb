require 'fluent/plugin/input'

require 'bindata'
require 'eventmachine'
require 'yaml'

dir = 'sflow/lib/sflow'
['models/ipv4header', 'models/tcpheader', 'models/udpheader', 'models/protocol', 'models/binary_models','parsers/parsers'].each do |req|
  require File.join(dir, req)
end

#$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'sflow', 'lib'))
#require 'sflow'

module Fluent::Plugin
  class SflowInput < Input
    Fluent::Plugin.register_input("sflow", self)

    helpers :server

    config_param :bind, :string, default: '0.0.0.0'
    config_param :port, :integer, default: 6343
    config_param :tag, :string

    def configure(conf)
      super

      # dummy data
      $switch_hash = {}
    end

    def start
      super

      server_create(:in_sflow_server, @port, bind: @bind, proto: :udp, max_bytes: 2048) do |data, sock|
        sflow = SflowParser.parse_packet(data)
        router.emit(@tag, Fluent::EventTime.now, sflow)
      end
    end

    def shutdown
      super
    end
  end
end
