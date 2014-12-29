require 'assert'
require 'hella-redis/connection_spy'

class HellaRedis::ConnectionSpy

  class UnitTests < Assert::Context
    desc "HellaRedis::ConnectionSpy"
    setup do
      @config = {
        :url    => 'redis://localhost:6379/0',
        :driver => 'ruby'
      }
      @connection_spy = HellaRedis::ConnectionSpy.new(@config)
    end
    subject{ @connection_spy }

    should have_readers :config, :with_calls, :redis_calls
    should have_imeths :with

    should "know its config" do
      assert_equal @config, subject.config
    end

    should "default its calls" do
      assert_equal [], subject.with_calls
      assert_equal [], subject.redis_calls
    end

    should "yield a redis spy using `with`" do
      yielded = nil
      subject.with{ |c| yielded = c }
      assert_instance_of RedisSpy, yielded
      assert_same subject.redis_calls, yielded.calls
    end

    should "track calls to with" do
      overrides = { :timeout => Factory.integer }
      subject.with(overrides){ |c| }
      call = subject.with_calls.last
      assert_equal [overrides], call.args
    end

  end

  class RedisSpyTests < UnitTests
    desc "RedisSpy"
    setup do
      @calls = []
      @redis_spy = RedisSpy.new(@config, @calls)
    end
    subject{ @redis_spy }

    should have_readers :calls

    should "allow passing a config object" do
      config = OpenStruct.new(@config)
      assert_nothing_raised{ RedisSpy.new(config, @calls) }
    end

    should "track redis calls made to it" do
      assert_true subject.respond_to?(:set)

      key, value = [Factory.string, Factory.string]
      subject.set(key, value)

      call = subject.calls.first
      assert_equal :set, call.command
      assert_equal [key, value], call.args
    end

    should "raise no method errors for non-redis methods" do
      assert_false subject.respond_to?(:super_awesome_set)
      assert_raises(NoMethodError) do
        subject.super_awesome_set(Factory.string, Factory.string)
      end
    end

  end

end
