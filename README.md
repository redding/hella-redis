# HellaRedis

It's-a hella-redis!

This gem is a wrapper that builds a connection pool of redis connections.  It also provides spies and test mode behavior to ease testing redis interactions.

## Usage

```ruby
# create
@redis = HellaRedis.new({
  :timeout  => 1,
  :size     => 5,
  :redis_ns => 'hella-redis-test',
  :driver   => 'ruby',
  :url      => 'redis://localhost:6379/0'
}) # => HellaRedis:ConnectionPool instance

# it's actually a pool of connections
@redis.connection do |connection|
  # checks out a connection so you can do something with it
  # will check it back in once the block has run
end
```

### Test Mode

```ruby
ENV['HELLA_REDIS_TEST_MODE'] = 'yes' # set to anything "truthy"

@redis_spy = HellaRedis.new({
  :timeout  => 1,
  :size     => 5,
  :redis_ns => 'hella-redis-test',
  :driver   => 'ruby',
  :url      => 'redis://localhost:6379/0'
}) # => HellaRedis::ConnectionPoolSpy instance

@redis_spy.connection do |connection|
  connection # => HellaRedis::ConnectionSpy instance
  connection.info
end

@redis_spy.calls.size # => 1
@redis_spy.calls.first.tap do |call|
  call.command # => :info
  call.args    # => nil
  call.block   # => nil
end

@redis_spy.connection_calls.size # => 1
@redis_spy.connection_calls.first.tap do |connection_call|
  connection_call.block # => block instance
end

Assert.stub(@redis_spy.connection_spy, :get).with('some-key'){ 'some-value' }
value = @redis_spy.connection do |connection|
  connection.get('some_key')
end
assert_equal 'some-value', value
@redis_spy.calls.size # => 1 (unchanged b/c we stubbed the :get method)
```

## Installation

Add this line to your application's Gemfile:

    gem 'hella-redis'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hella-redis

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
