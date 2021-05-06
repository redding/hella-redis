# frozen_string_literal: true

require "connection_pool"
require "redis"
require "redis-namespace"

module HellaRedis
  class ConnectionPool
    def initialize(config)
      @pool =
        ::ConnectionPool.new(
          timeout: config.timeout,
          size: config.size,
        ) do
          ::Redis::Namespace.new(
            config.redis_ns,
            redis: ::Redis.new(url: config.url, driver: config.driver),
          )
        end
    end

    def connection
      @pool.with do |connection|
        yield connection if block_given?
      end
    end
  end
end
