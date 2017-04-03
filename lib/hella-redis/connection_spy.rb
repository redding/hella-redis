require 'redis'

module HellaRedis

  class ConnectionSpy

    attr_reader :calls

    def initialize(config)
      @instance = ::Redis.new({
        :url    => config.url,
        :driver => config.driver
      })
      @calls = []
    end

    def pipelined
      @calls << ConnectionCall.new(:pipelined, [])
      yield self
    end

    def multi
      @calls << ConnectionCall.new(:multi, [])
      yield self
    end

    def method_missing(name, *args, &block)
      if self.respond_to?(name)
        @calls << ConnectionCall.new(name, args, block)
      else
        super
      end
    end

    def respond_to?(*args)
      super || @instance.respond_to?(*args)
    end

    ConnectionCall = Struct.new(:command, :args, :block)

  end

end
