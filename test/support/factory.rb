require 'assert/factory'
require 'hella-redis'

module Factory
  extend Assert::Factory

  def self.config(args = nil)
    HellaRedis::Config.new(self.config_args(args))
  end

  def self.config_args(args = nil)
    { :timeout  => 1,
      :size     => 5,
      :redis_ns => 'hella-redis-test',
      :url      => 'redis://localhost:6379/0',
      :driver   => 'ruby'
    }.merge(args || {})
  end

end
