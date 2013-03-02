# HellaRedis

It's-a hella-redis!

## Usage

### RedisConnection

```ruby
# config and create a connection
@config = OpenStruct.new({
  :timeout  => 1,
  :size     => 5,
  :redis_ns => 'hella-redis-test',
  :driver   => 'ruby',
  :url      => 'redis://localhost:6379/0'
})
@conn = HellaRedis::RedisConnection.new(@config)

# it's actually a pool of connections
@conn.with do |conn|
  # get a connection and do something with it
end
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
