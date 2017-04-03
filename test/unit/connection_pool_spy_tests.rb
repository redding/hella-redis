require 'assert'
require 'hella-redis/connection_pool_spy'

require 'hella-redis/connection_spy'

class HellaRedis::ConnectionPoolSpy

  class UnitTests < Assert::Context
    desc "HellaRedis::ConnectionPoolSpy"
    setup do
      Assert.stub(HellaRedis::ConnectionSpy, :new) do |*args|
        @connection_spy_created_with = args
        Assert.stub_send(HellaRedis::ConnectionSpy, :new, *args)
      end

      @config              = Factory.config
      @connection_pool_spy = HellaRedis::ConnectionPoolSpy.new(@config)
    end
    subject{ @connection_pool_spy }

    should have_readers :config, :connection_spy, :connection_calls
    should have_imeths :calls, :connection

    should "know its config and redis spy" do
      assert_equal @config, subject.config
      assert_instance_of HellaRedis::ConnectionSpy, subject.connection_spy
      exp = [@config]
      assert_equal exp, @connection_spy_created_with
    end

    should "default its connection calls" do
      assert_equal [], subject.connection_calls
    end

    should "know its calls" do
      assert_same subject.connection_spy.calls, subject.calls
    end

    should "yield its connection spy using `connection`" do
      yielded = nil
      subject.connection{ |c| yielded = c }

      assert_same subject.connection_spy, yielded
    end

    should "track calls to connection" do
      block = proc{ |c| Factory.string }
      subject.connection(&block)

      call = subject.connection_calls.last
      assert_equal block, call.block
    end

  end

end
