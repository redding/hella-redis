# frozen_string_literal: true

require "assert/factory"
require "hella-redis"

module Factory
  extend Assert::Factory

  def self.config(args = nil)
    HellaRedis::Config.new(self.config_args(args))
  end

  def self.config_args(args = nil)
    { :timeout  => Factory.integer,
      :size     => Factory.integer(5),
      :redis_ns => "hella-redis-test-#{Factory.string}",
      :url      => "redis://localhost:6379/0",
      :driver   => "ruby"
    }.merge(args || {})
  end
end
