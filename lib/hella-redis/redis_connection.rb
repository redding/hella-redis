require 'redis'
require 'redis-namespace'
require 'connection_pool'
require 'hella-redis/version'

module HellaRedis::RedisConnection

  def self.new(config)
    @pool = ::ConnectionPool.new(:timeout => config.timeout, :size => config.size) do
      ::Redis::Namespace.new(config.redis_ns, {
        :redis => ::Redis.connect({
          :url    => config.url,
          :driver => config.driver
        })
      })
    end
  end

end
