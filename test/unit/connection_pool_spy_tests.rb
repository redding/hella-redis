# frozen_string_literal: true

require "assert"
require "hella-redis/connection_pool_spy"

require "hella-redis/connection_spy"

class HellaRedis::ConnectionPoolSpy
  class UnitTests < Assert::Context
    desc "HellaRedis::ConnectionPoolSpy"
    setup do
      Assert.stub_tap_on_call(HellaRedis::ConnectionSpy, :new) do |_, call|
        @connection_spy_new_call = call
      end

      @config              = Factory.config
      @connection_pool_spy = HellaRedis::ConnectionPoolSpy.new(@config)
    end
    subject{ @connection_pool_spy }

    should have_readers :config, :connection_spy, :connection_calls
    should have_imeths :calls, :connection, :reset!

    should "know its config and redis spy" do
      assert_that(subject.config).is(@config)
      assert_that(subject.connection_spy)
        .is_an_instance_of(HellaRedis::ConnectionSpy)
      assert_that(@connection_spy_new_call.args).equals([@config])
    end

    should "default its connection calls" do
      assert_that(subject.connection_calls).equals([])
    end

    should "know its calls" do
      assert_that(subject.calls).is(subject.connection_spy.calls)
    end

    should "yield its connection spy using `connection`" do
      yielded = nil
      subject.connection{ |c| yielded = c }

      assert_that(yielded).is(subject.connection_spy)
    end

    should "track calls to connection" do
      block = proc{ |_c| Factory.string }
      subject.connection(&block)

      call = subject.connection_calls.last
      assert_that(call.block).is(block)
    end

    should "remove all calls on `reset!`" do
      subject.connection(&:info)

      assert_that(subject.calls.empty?).is_false
      assert_that(subject.connection_calls.empty?).is_false

      subject.reset!

      assert_that(subject.calls.empty?).is_true
      assert_that(subject.connection_calls.empty?).is_true
    end

    should "know if it is equal to another pool spy" do
      equal_pool_spy = HellaRedis::ConnectionPoolSpy.new(@config)
      assert_that(equal_pool_spy).equals(subject)

      not_equal_config = HellaRedis::ConnectionPoolSpy.new(Factory.config)
      assert_that(not_equal_config).does_not_equal(subject)
    end
  end
end
