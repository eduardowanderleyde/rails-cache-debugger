# Rails Cache Debugger

A gem to help debug Rails cache operations by providing visibility into cache hits, misses, writes, and deletes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-cache-debugger'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rails-cache-debugger
```

## Usage

### Basic Usage

```ruby
# Configure the debugger (optional)
Rails::Cache::Debugger.configure do |config|
  config.enabled = true
  config.log_events = [
    "cache_read.active_support",
    "cache_write.active_support",
    "cache_fetch_hit.active_support"
  ]
end

# Use the debugger
cache = Rails.cache
debugger = Rails::Cache::Debugger.new(cache)

# Your cache operations will be automatically logged
debugger.write("key", "value")
debugger.read("key")
debugger.fetch("key") { "value" }
```

### Output Example

```
[CacheDebugger] WRITE key: key (1.23ms)
[CacheDebugger] HIT key: key (0.45ms)
[CacheDebugger] FETCH_HIT key: key (0.67ms)
```

### Available Operations

The debugger supports all standard Rails cache operations:

- `read(key, **options)`
- `write(key, value, **options)`
- `delete(key, **options)`
- `exist?(key, **options)`
- `fetch(key, **options) { block }`

### Configuration Options

```ruby
Rails::Cache::Debugger.configure do |config|
  # Enable/disable the debugger
  config.enabled = true

  # Configure which events to log
  config.log_events = [
    "cache_read.active_support",
    "cache_write.active_support",
    "cache_fetch_hit.active_support"
  ]
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/eduardowanderleyde/rails-cache-debugger>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
