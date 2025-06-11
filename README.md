# Rails Cache Debugger

[![Gem Version](https://badge.fury.io/rb/rails-cache-debugger.svg)](https://badge.fury.io/rb/rails-cache-debugger)
[![Build Status](https://github.com/yourusername/rails-cache-debugger/workflows/CI/badge.svg)](https://github.com/yourusername/rails-cache-debugger/actions)
[![Code Climate](https://codeclimate.com/github/yourusername/rails-cache-debugger/badges/gpa.svg)](https://codeclimate.com/github/yourusername/rails-cache-debugger)
[![Test Coverage](https://codeclimate.com/github/yourusername/rails-cache-debugger/badges/coverage.svg)](https://codeclimate.com/github/yourusername/rails-cache-debugger/coverage)
[![Documentation](https://img.shields.io/badge/docs-rubydoc.info-blue.svg)](https://rubydoc.info/gems/rails-cache-debugger)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yourusername/rails-cache-debugger/blob/main/LICENSE.txt)
[![Ruby Version](https://img.shields.io/badge/ruby-2.7%2B-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-6.0%2B-blue.svg)](https://rubyonrails.org/)

A powerful debugging tool for Rails cache operations. This gem provides detailed logging, performance metrics, and event tracking for cache operations in your Rails application.

## Features

- Detailed logging of cache operations (read, write, delete, etc.)
- Performance metrics for cache operations
- Event tracking and filtering
- Customizable log formats (text and JSON)
- Sampling rate control for production environments
- Extensible event handling system
- YARD documentation for all classes and methods
- Improved error handling and validation
- Better configuration management
- Enhanced version management

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails-cache-debugger"
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

The gem will automatically start logging cache operations when your Rails application starts. By default, it logs cache hits, misses, writes, and deletes.

### Configuration

You can configure the debugger in your Rails application:

```ruby
# config/initializers/rails_cache_debugger.rb

Rails::Cache::Debugger.configure do |config|
  # Enable or disable the debugger
  config.enabled = true

  # Set the logger
  config.logger = Rails.logger

  # Set the log format (text or json)
  config.log_format = :text

  # Set the sampling rate (0.0 to 1.0)
  config.sampling_rate = 1.0

  # Set the events to log
  config.log_events = %w[
    cache_read.active_support
    cache_write.active_support
    cache_delete.active_support
    cache_exist.active_support
    cache_fetch_hit.active_support
    cache_fetch_miss.active_support
  ]

  # Set a filter for events
  config.log_filter = lambda do |event, details|
    return false if details[:key].to_s.start_with?("_")
    return false if details[:duration] < 1 # Ignore very fast operations
    true
  end

  # Set an event handler
  config.on_event = lambda do |event, details|
    # You can add custom event handling here
    # For example, sending events to a monitoring service
  end
end
```

### Advanced Usage

#### Custom Event Handling

You can add custom event handling to send events to monitoring services or perform other actions:

```ruby
Rails::Cache::Debugger.configure do |config|
  config.on_event = lambda do |event, details|
    # Send to monitoring service
    MonitoringService.track_cache_event(event, details)

    # Or perform other actions
    if details[:duration] > 1000 # 1 second
      Rails.logger.warn("Slow cache operation: #{event} (#{details[:duration]}ms)")
    end
  end
end
```

#### Event Filtering

You can filter events based on your needs:

```ruby
Rails::Cache::Debugger.configure do |config|
  config.log_filter = lambda do |event, details|
    # Only log events for specific keys
    return false unless details[:key].to_s.start_with?("user:")

    # Only log slow operations
    return false if details[:duration] < 100 # 100ms

    # Only log in development
    return false unless Rails.env.development?

    true
  end
end
```

#### JSON Logging

For better integration with log aggregation services, you can use JSON logging:

```ruby
Rails::Cache::Debugger.configure do |config|
  config.log_format = :json
end
```

This will output logs in JSON format:

```json
{
  "event": "cache_read.active_support",
  "timestamp": "2024-03-20T12:34:56Z",
  "details": {
    "key": "user:123",
    "hit": true,
    "duration": 1.23
  }
}
```

#### Sampling Rate

In production, you might want to sample only a portion of the events to reduce overhead:

```ruby
Rails::Cache::Debugger.configure do |config|
  config.sampling_rate = 0.1 # Log only 10% of events
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/yourusername/rails-cache-debugger>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/yourusername/rails-cache-debugger/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rails Cache Debugger project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yourusername/rails-cache-debugger/blob/main/CODE_OF_CONDUCT.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Support

- [Issues](https://github.com/eduardowanderleyde/rails-cache-debugger/issues)
- [Documentation](https://rubydoc.info/gems/rails-cache-debugger)
- [Wiki](https://github.com/eduardowanderleyde/rails-cache-debugger/wiki)
