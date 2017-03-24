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
  module DatagramHandler
    def initialize args = {}
      @callbacks = args[:callbacks]
    end

    def receive_data(data)
      sflow = SflowParser.parse_packet(data)
      @callbacks.each do |callback|
        callback.call sflow
      end
    end
  end

  class Collector
    def initialize args = {}
      @host = args[:host] || "127.0.0.1"
      @port = (args[:port] || 6343).to_i

      @callbacks = []

      EventMachine::open_datagram_socket(@host, @port, DatagramHandler,
                                        :callbacks => @callbacks)
    end

    def on_sflow &proc
      @callbacks << proc
    end
  end

  class SflowInput < Input
    Fluent::Plugin.register_input("sflow", self)

    config_param :bind, :string, default: '0.0.0.0'
    config_param :port, :integer, default: 6343
    config_param :tag, :string

    def configure(conf)
      super

      @th_evrun = nil
      @stop_th = false
    end

    def start
      super

      @th_evrun = Thread.new(&method(:run))
    end

    def run
      EM::run do
        c = Collector.new({:host => @host, @port => @port})
        c.on_sflow do |sflow|
          router.emit(@tag, Engine.now, sflow)
        end
      end
    end

    def shutdown
      super

      if @th_evrun and @th_evrun.alive?
        @stop_th = true
        @th_evrun.join
        @stop_th = false
      end
    end
  end
end
