# frozen_string_literal: true

require "assert"
require "hella-redis"

module HellaRedis
  class UnitTests < Assert::Context
    desc "HellaRedis"
    setup do
      @config_args = Factory.config_args
      @module      = HellaRedis
    end
    subject{ @module }

    should have_imeths :new, :real, :mock
  end

  class NewRealMockTests < UnitTests
    setup do
      @config = Config.new(@config_args)

      @pool = ConnectionPool.new(@config)
      @pool_new_called_with = nil
      Assert.stub(ConnectionPool, :new) do |*args|
        @pool_new_called_with = args
        @pool
      end

      @pool_spy = ConnectionPoolSpy.new(@config)
      @pool_spy_new_called_with = nil
      Assert.stub(ConnectionPoolSpy, :new) do |*args|
        @pool_spy_new_called_with = args
        @pool_spy
      end
    end
  end

  class NewTests < NewRealMockTests
    desc "`new`"
    setup do
      @current_test_mode = ENV["HELLA_REDIS_TEST_MODE"]
      ENV["HELLA_REDIS_TEST_MODE"] = "yes"
    end
    teardown do
      ENV["HELLA_REDIS_TEST_MODE"] = @current_test_mode
    end

    should "build and return a new connection pool" do
      ENV.delete("HELLA_REDIS_TEST_MODE")
      redis = subject.new(@config_args)

      assert_equal [@config], @pool_new_called_with
      assert_equal @pool, redis
    end

    should "build and return a connection pool spy in test mode" do
      redis = subject.new(@config_args)

      assert_equal [@config], @pool_spy_new_called_with
      assert_equal @pool_spy, redis
    end
  end

  class RealTests < NewRealMockTests
    desc "`real`"

    should "build and return a connection pool spy" do
      redis = subject.real(@config_args)

      assert_equal [@config], @pool_new_called_with
      assert_equal @pool, redis
    end
  end

  class MockTests < NewRealMockTests
    desc "`mock`"

    should "build and return a connection pool spy" do
      redis = subject.mock(@config_args)

      assert_equal [@config], @pool_spy_new_called_with
      assert_equal @pool_spy, redis
    end
  end

  class ConfigTests < UnitTests
    desc "Config"
    setup do
      @config = Config.new(@config_args)
    end
    subject{ @config }

    should have_readers :url, :driver, :redis_ns, :timeout, :size

    should "know its attributes" do
      assert_equal @config_args[:url],      subject.url
      assert_equal @config_args[:driver],   subject.driver
      assert_equal @config_args[:redis_ns], subject.redis_ns
      assert_equal @config_args[:timeout],  subject.timeout
      assert_equal @config_args[:size],     subject.size
    end

    should "default its size" do
      @config_args.delete(:size)
      config = Config.new(@config_args)
      assert_equal 1, config.size
    end

    should "know if it is equal to another config" do
      equal_config = Config.new(@config_args)
      assert_equal subject, equal_config

      not_equal_config = Config.new
      assert_not_equal subject, not_equal_config
    end
  end
end
