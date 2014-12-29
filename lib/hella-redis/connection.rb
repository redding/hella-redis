require 'connection_pool'
require 'redis'
require 'redis-namespace'

module HellaRedis

  module Connection

    def self.new(config)
      config = Config.new(config) if config.kind_of?(::Hash)
      ::ConnectionPool.new(:timeout => config.timeout, :size => config.size) do
        ::Redis::Namespace.new(config.redis_ns, {
          :redis => ::Redis.connect({
            :url    => config.url,
            :driver => config.driver
          })
        })
      end
    end

    class Config
      attr_reader :url, :driver, :redis_ns, :timeout, :size

      def initialize(args)
        @url      = args[:url]
        @driver   = args[:driver]
        @redis_ns = args[:ns]
        @timeout  = args[:timeout]
        @size     = args[:size]
      end
    end

  end

end
