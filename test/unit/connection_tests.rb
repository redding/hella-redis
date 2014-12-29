require 'assert'
require 'hella-redis/connection'

require 'connection_pool'
require 'ostruct'

module HellaRedis::Connection

  class UnitTests < Assert::Context
    desc "HellaRedis::Connection"
    setup do
      @config_hash = {
        :timeout  => 1,
        :size     => 5,
        :redis_ns => 'hella-redis-test',
        :driver   => 'ruby',
        :url      => 'redis://localhost:6379/0'
      }
      @conn = HellaRedis::Connection.new(@config_hash)
    end
    subject{ @conn }

    should "build a connection pool" do
      assert_instance_of ::ConnectionPool, subject
    end

    should "connect to the redis instance that was provided" do
      assert_nothing_raised do
        subject.with{ |c| c.info }
      end
    end

    should "build a redis namespace and yield it using `with`" do
      subject.with do |conn|
        assert_instance_of ::Redis::Namespace, conn
      end
    end

    should "allow passing a config object when building a connection" do
      conn = nil
      assert_nothing_raised do
        config = OpenStruct.new(@config_hash)
        conn = HellaRedis::Connection.new(config)
      end
      assert_instance_of ::ConnectionPool, conn
    end

  end

  class ConfigTests < UnitTests
    desc "Config"
    setup do
      @config = Config.new(@config_hash)
    end
    subject{ @config }

    should have_readers :url, :driver, :redis_ns, :timeout, :size

    should "know its attributes" do
      assert_equal @config_hash[:url],     subject.url
      assert_equal @config_hash[:driver],  subject.driver
      assert_equal @config_hash[:ns],      subject.redis_ns
      assert_equal @config_hash[:timeout], subject.timeout
      assert_equal @config_hash[:size],    subject.size
    end

    should "default its size" do
      @config_hash.delete(:size)
      config = Config.new(@config_hash)
      assert_equal 1, config.size
    end

  end

end
