require 'assert'
require 'hella-redis/redis_connection'
require 'connection_pool'
require 'ostruct'

module HellaRedis::RedisConnection

  class BaseTests < Assert::Context
    desc "a RedisConnection"
    setup do
      @config = OpenStruct.new({
        :timeout  => 1,
        :size     => 5,
        :redis_ns => 'hella-redis-test',
        :driver   => 'ruby',
        :url      => 'redis://localhost:6379/0'
      })
      @conn = HellaRedis::RedisConnection.new(@config)
    end
    subject{ @conn }

    should "be a connection pool with the configured size and timeout" do
      assert_kind_of ConnectionPool, subject
    end

    should "connect to the redis url" do
      assert_nothing_raised do
        subject.with do |conn|
          assert_kind_of Redis::Namespace, conn
        end
      end
    end

  end

end
