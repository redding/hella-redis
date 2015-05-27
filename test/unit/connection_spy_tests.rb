require 'assert'
require 'hella-redis/connection_spy'

class HellaRedis::ConnectionSpy

  class UnitTests < Assert::Context
    setup do
      @config = {
        :url    => 'redis://localhost:6379/0',
        :driver => 'ruby'
      }
    end

  end

  class ConnectionSpyTests < UnitTests
    desc "HellaRedis::ConnectionSpy"
    setup do
      @connection_spy = HellaRedis::ConnectionSpy.new(@config)
    end
    subject{ @connection_spy }

    should have_readers :config, :redis_spy, :with_calls
    should have_imeths :with, :redis_calls

    should "know its config and redis spy" do
      assert_equal @config, subject.config
      assert_instance_of HellaRedis::RedisSpy, subject.redis_spy
    end

    should "default its with calls" do
      assert_equal [], subject.with_calls
    end

    should "know its redis spy's calls" do
      assert_same subject.redis_spy.calls, subject.redis_calls
    end

    should "yield its redis spy using `with`" do
      yielded = nil
      subject.with{ |c| yielded = c }
      assert_same subject.redis_spy, yielded
    end

    should "track calls to with" do
      overrides = { :timeout => Factory.integer }
      block = proc{ |c| Factory.string }
      subject.with(overrides, &block)
      call = subject.with_calls.last
      assert_equal [overrides], call.args
      assert_equal block, call.block
    end

    should "allow passing a custom redis spy" do
      redis_spy = Factory.string
      spy = HellaRedis::ConnectionSpy.new(@config, redis_spy)
      assert_equal redis_spy, spy.redis_spy
    end

  end

  class RedisSpyTests < UnitTests
    desc "HellaRedis::RedisSpy"
    setup do
      @redis_spy = HellaRedis::RedisSpy.new(@config)
    end
    subject{ @redis_spy }

    should have_readers :pipelined, :multi, :calls

    should "default its calls" do
      assert_equal [], subject.calls
    end

    should "allow passing a config object" do
      config = OpenStruct.new(@config)
      assert_nothing_raised{ HellaRedis::RedisSpy.new(config) }
    end

    should "track redis calls made to it" do
      assert_true subject.respond_to?(:set)

      key, value = [Factory.string, Factory.string]
      subject.set(key, value)

      call = subject.calls.first
      assert_equal :set, call.command
      assert_equal [key, value], call.args
    end

    should "track the call and yield itself using `pipelined`" do
      subject.pipelined{ |c| c.set(Factory.string, Factory.string) }
      assert_equal [:pipelined, :set], subject.calls.map(&:command)
    end

    should "track the call and yield itself using `multi`" do
      subject.multi{ |c| c.set(Factory.string, Factory.string) }
      assert_equal [:multi, :set], subject.calls.map(&:command)
    end

    should "raise no method errors for non-redis methods" do
      assert_false subject.respond_to?(:super_awesome_set)
      assert_raises(NoMethodError) do
        subject.super_awesome_set(Factory.string, Factory.string)
      end
    end

  end

end
