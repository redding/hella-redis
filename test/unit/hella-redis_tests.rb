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
      Assert.stub_on_call(ConnectionPool, :new) do |call|
        @pool_new_call = call
        @pool
      end

      @pool_spy = ConnectionPoolSpy.new(@config)
      @pool_spy_new_called_with = nil
      Assert.stub_on_call(ConnectionPoolSpy, :new) do |call|
        @pool_spy_new_call = call
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

      assert_that(@pool_new_call.args).equals([@config])
      assert_that(redis).equals(@pool)
    end

    should "build and return a connection pool spy in test mode" do
      redis = subject.new(@config_args)

      assert_that(@pool_spy_new_call.args).equals([@config])
      assert_that(redis).equals(@pool_spy)
    end
  end

  class RealTests < NewRealMockTests
    desc "`real`"

    should "build and return a connection pool spy" do
      redis = subject.real(@config_args)

      assert_that(@pool_new_call.args).equals([@config])
      assert_that(redis).equals(@pool)
    end
  end

  class MockTests < NewRealMockTests
    desc "`mock`"

    should "build and return a connection pool spy" do
      redis = subject.mock(@config_args)

      assert_that(@pool_spy_new_call.args).equals([@config])
      assert_that(redis).equals(@pool_spy)
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
      assert_that(subject.url).equals(@config_args[:url])
      assert_that(subject.driver).equals(@config_args[:driver])
      assert_that(subject.redis_ns).equals(@config_args[:redis_ns])
      assert_that(subject.timeout).equals(@config_args[:timeout])
      assert_that(subject.size).equals(@config_args[:size])
    end

    should "default its size" do
      @config_args.delete(:size)
      config = Config.new(@config_args)
      assert_that(config.size).equals(1)
    end

    should "know if it is equal to another config" do
      equal_config = Config.new(@config_args)
      assert_that(subject).equals(equal_config)

      not_equal_config = Config.new
      assert_that(subject).does_not_equal(not_equal_config)
    end
  end
end
