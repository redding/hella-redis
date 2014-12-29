require 'redis'
require 'hella-redis/connection'

module HellaRedis

  class ConnectionSpy

    attr_reader :config
    attr_reader :with_calls, :redis_calls

    def initialize(config)
      @config      = config
      @with_calls  = []
      @redis_calls = []
      @redis       = RedisSpy.new(config, @redis_calls)
    end

    def with(*args, &block)
      @with_calls << WithCall.new(args)
      block.call(@redis)
    end

    class RedisSpy
      attr_reader :calls

      def initialize(config, calls)
        # mimic the real conection behavior, accept hash or object
        config = Connection::Config.new(config) if config.kind_of?(::Hash)
        @instance = ::Redis.new({
          :url    => config.url,
          :driver => config.driver
        })
        @calls = calls
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

    WithCall  = Struct.new(:args)
    RedisCall = Struct.new(:command, :args, :block)

  end

end
