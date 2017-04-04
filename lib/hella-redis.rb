require 'hella-redis/version'
require 'hella-redis/connection_pool'
require 'hella-redis/connection_pool_spy'

module HellaRedis

  def self.new(args)
    self.send(ENV['HELLA_REDIS_TEST_MODE'] ? :mock : :real, args)
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

    def ==(other_config)
      if other_config.kind_of?(Config)
        self.url      == other_config.url      &&
        self.driver   == other_config.driver   &&
        self.redis_ns == other_config.redis_ns &&
        self.timeout  == other_config.timeout  &&
        self.size     == other_config.size
      else
        super
      end
    end

  end

end
