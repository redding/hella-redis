require 'assert'
require 'hella-redis/connection_pool'

require 'redis-namespace'

class HellaRedis::ConnectionPool

  class UnitTests < Assert::Context
    desc "HellaRedis::Connection"
    setup do
      @connection_pool = HellaRedis::ConnectionPool.new(Factory.config)
    end
    subject{ @connection_pool }

    should have_imeths :connection

    should "build a redis namespace and yield it using `connection`" do
      subject.connection do |connection|
        assert_instance_of ::Redis::Namespace, connection
        assert_nothing_raised{ connection.get(Factory.string) }
      end
    end

  end

end
