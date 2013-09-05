require 'assert'
require 'hella-redis/connection'

require 'connection_pool'
require 'ostruct'

module HellaRedis::Connection

  class UnitTests < Assert::Context
    desc "a RedisConnection"
    setup do
      @config = OpenStruct.new({
        :timeout  => 1,
        :size     => 5,
        :redis_ns => 'hella-redis-test',
        :driver   => 'ruby',
        :url      => 'redis://localhost:6379/0'
      })
      @conn = HellaRedis::Connection.new(@config)
    end
    subject{ @conn }

    should "return a connection pool" do
      assert_kind_of ConnectionPool, subject
    end

    should "connect to the redis instance that was provided" do
      assert_nothing_raised do
        subject.with{ |c| c.info }
      end
    end

    should "build a redis namespace and yield it using #with" do
      subject.with do |conn|
        assert_kind_of Redis::Namespace, conn
      end
    end

  end

end
