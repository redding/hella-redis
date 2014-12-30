require 'redis'
require 'hella-redis/connection'

module HellaRedis

  class ConnectionSpy

    attr_reader :config, :redis_spy, :with_calls

    def initialize(config, redis_spy = nil)
      @config     = config
      @with_calls = []
      @redis_spy  = redis_spy || RedisSpy.new(config)
    end

    def with(*args, &block)
      @with_calls << WithCall.new(args, block)
      block.call(@redis_spy)
    end

    def redis_calls
      @redis_spy.calls
    end

  end

  class RedisSpy

    attr_reader :calls

    def initialize(config)
      # mimic the real conection behavior, accept hash or object
      config = Connection::Config.new(config) if config.kind_of?(::Hash)
      @instance = ::Redis.new({
        :url    => config.url,
        :driver => config.driver
      })
      @calls = []
    end

    def method_missing(name, *args, &block)
      if self.respond_to?(name)
        @calls << RedisCall.new(name, args, block)
      else
        super
      end
    end

    def respond_to?(*args)
      super || @instance.respond_to?(*args)
    end

  end

  WithCall  = Struct.new(:args, :block)
  RedisCall = Struct.new(:command, :args, :block)

end
