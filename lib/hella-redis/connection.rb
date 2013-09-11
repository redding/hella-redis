require 'connection_pool'
require 'redis'
require 'redis-namespace'

module HellaRedis

  module Connection

    def self.new(config)
      ::ConnectionPool.new(:timeout => config.timeout, :size => config.size) do
        ::Redis::Namespace.new(config.redis_ns, {
          :redis => ::Redis.connect({
            :url    => config.url,
            :driver => config.driver
          })
        })
      end
    end

  end

end
