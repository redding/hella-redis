require 'assert'
require 'hella-redis/connection_spy'

class HellaRedis::ConnectionSpy

  class UnitTests < Assert::Context
    desc "HellaRedis::ConnectionSpy"
    setup do
      @connection_spy = HellaRedis::ConnectionSpy.new(Factory.config)
    end
    subject{ @connection_spy }

    should have_readers :calls
    should have_imeths :pipelined, :multi

    should "default its calls" do
      assert_equal [], subject.calls
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
