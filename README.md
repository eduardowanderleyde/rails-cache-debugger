# Rails Cache Debugger

[![Gem Version](https://badge.fury.io/rb/rails-cache-debugger.svg)](https://badge.fury.io/rb/rails-cache-debugger)
[![Build Status](https://github.com/eduardowanderleyde/rails-cache-debugger/workflows/CI/badge.svg)](https://github.com/eduardowanderleyde/rails-cache-debugger/actions)
[![Code Climate](https://codeclimate.com/github/eduardowanderleyde/rails-cache-debugger/badges/gpa.svg)](https://codeclimate.com/github/eduardowanderleyde/rails-cache-debugger)
[![Test Coverage](https://codeclimate.com/github/eduardowanderleyde/rails-cache-debugger/badges/coverage.svg)](https://codeclimate.com/github/eduardowanderleyde/rails-cache-debugger/coverage)

A gem to help debug Rails cache operations by providing visibility into cache hits, misses, writes, and deletes.

## Features

- 🔍 Detailed cache operation monitoring
- ⚡ Operation performance measurement
- 🔧 Flexible configuration
- 📊 Formatted and readable logs
- 🛠 Support for all Rails cache stores
- 🧪 Comprehensive tests
- 📝 Detailed documentation

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

### Basic Configuration

```ruby
# config/initializers/cache_debugger.rb
Rails::Cache::Debugger.configure do |config|
  config.enabled = true
  config.log_events = [
    "cache_read.active_support",
    "cache_write.active_support",
    "cache_fetch_hit.active_support"
  ]
end
```

### Basic Usage

```ruby
# Initialize the debugger
cache = Rails.cache
debugger = Rails::Cache::Debugger.new(cache)

# Cache operations will be automatically logged
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

- `read(key, **options)` - Read a value from cache
- `write(key, value, **options)` - Write a value to cache
- `delete(key, **options)` - Remove a value from cache
- `exist?(key, **options)` - Check if a key exists
- `fetch(key, **options) { block }` - Fetch a value or execute block

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

  # Configure log format (optional)
  config.log_format = :text # or :json
end
```

## Use Cases

### Performance Debugging

```ruby
# Identify slow operations
debugger.fetch("slow_key") do
  sleep(1)
  "value"
end
# Output: [CacheDebugger] FETCH_MISS key: slow_key (1000.45ms)
```

### Cache Monitoring

```ruby
# Monitor usage patterns
debugger.read("frequent_key")
debugger.read("frequent_key")
# Output: [CacheDebugger] MISS key: frequent_key (0.45ms)
# Output: [CacheDebugger] HIT key: frequent_key (0.23ms)
```

### Cache Analysis

```ruby
# Check hits/misses
debugger.exist?("important_key")
debugger.read("important_key")
# Output: [CacheDebugger] EXIST key: important_key (0.12ms)
# Output: [CacheDebugger] HIT key: important_key (0.34ms)
```

## Troubleshooting

### Common Issues

1. **Logs not appearing**
   - Check if debugger is enabled
   - Confirm correct events are configured
   - Check log permissions

2. **Performance Degradation**
   - Disable debugger in production
   - Configure only necessary events
   - Use appropriate log format

### Best Practices

1. **Development**
   - Keep debugger enabled
   - Monitor cache patterns
   - Optimize based on logs

2. **Production**
   - Use with moderation
   - Configure only critical events
   - Monitor performance impact

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

This project adheres to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Support

- [Issues](https://github.com/eduardowanderleyde/rails-cache-debugger/issues)
- [Documentation](https://rubydoc.info/gems/rails-cache-debugger)
- [Wiki](https://github.com/eduardowanderleyde/rails-cache-debugger/wiki)
