# frozen_string_literal: true

require "hella-redis/version"
require "hella-redis/connection_pool"
require "hella-redis/connection_pool_spy"

module HellaRedis
  def self.new(args)
    send(ENV["HELLA_REDIS_TEST_MODE"] ? :mock : :real, args)
  end

  def self.real(args)
    ConnectionPool.new(Config.new(args))
  end

  def self.mock(args)
    ConnectionPoolSpy.new(Config.new(args))
  end

  class Config
    attr_reader :url, :driver, :redis_ns, :timeout, :size

    def initialize(args = nil)
      args ||= {}
      @url      = args[:url]
      @driver   = args[:driver]
      @redis_ns = args[:redis_ns]
      @timeout  = args[:timeout]
      @size     = args[:size] || 1
    end

    def ==(other)
      if other.is_a?(Config)
        url      == other.url      &&
        driver   == other.driver   &&
        redis_ns == other.redis_ns &&
        timeout  == other.timeout  &&
        size     == other.size
      else
        super
      end
    end
  end
end
