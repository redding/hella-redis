# frozen_string_literal: true

require "assert"
require "hella-redis/connection_spy"

class HellaRedis::ConnectionSpy
  class UnitTests < Assert::Context
    desc "HellaRedis::ConnectionSpy"
    setup do
      @connection_spy = HellaRedis::ConnectionSpy.new(Factory.config)
    end
    subject{ @connection_spy }

    should have_accessors :calls
    should have_imeths :pipelined, :multi

    should "default its calls" do
      assert_that(subject.calls).equals([])
    end

    should "track redis calls made to it" do
      assert_that(subject.respond_to?(:set)).is_true

      key, value = [Factory.string, Factory.string]
      subject.set(key, value)

      call = subject.calls.first
      assert_that(call.command).equals(:set)
      assert_that(call.args).equals([key, value])
    end

    should "track the call and yield itself using `pipelined`" do
      subject.pipelined{ |c| c.set(Factory.string, Factory.string) }
      assert_that(subject.calls.map(&:command)).equals([:pipelined, :set])
    end

    should "track the call and yield itself using `multi`" do
      subject.multi{ |c| c.set(Factory.string, Factory.string) }
      assert_that(subject.calls.map(&:command)).equals([:multi, :set])
    end

    should "raise no method errors for non-redis methods" do
      assert_that(subject.respond_to?(:super_awesome_set)).is_false
      assert_that{
        subject.super_awesome_set(Factory.string, Factory.string)
      }.raises(NoMethodError)
    end
  end
end
