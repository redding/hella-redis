require 'redis'
require 'hella-redis/connection_pool'
require 'hella-redis/connection_spy'

module HellaRedis

  class ConnectionPoolSpy

    attr_reader :config, :connection_spy, :connection_calls

    def initialize(config)
      @config           = config
      @connection_spy   = ConnectionSpy.new(config)
      @connection_calls = []
    end

    def calls
      @connection_spy.calls
    end

    def connection(&block)
      @connection_calls << ConnectionCall.new(block)
      block.call(@connection_spy)
    end

    ConnectionCall = Struct.new(:block)

  end

end
