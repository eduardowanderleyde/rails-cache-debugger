# Rails Cache Debugger API Documentation

This document provides detailed information about the Rails Cache Debugger API.

## Configuration

### Rails::Cache::Debugger.configure

Configures the debugger with the provided block.

```ruby
Rails::Cache::Debugger.configure do |config|
  config.enabled = true
  config.log_events = ["cache_read.active_support"]
end
```

#### Options

- `enabled` (Boolean): Enable/disable the debugger
- `log_events` (Array): List of events to log
- `log_format` (Symbol): Log format (`:text` or `:json`)
- `sampling_rate` (Float): Rate of operations to log (0.0 to 1.0)
- `log_filter` (Proc): Custom filter for log events
- `on_event` (Proc): Custom event handler

## Instance Methods

### #initialize(cache)

Creates a new debugger instance.

```ruby
debugger = Rails::Cache::Debugger.new(Rails.cache)
```

#### Parameters

- `cache` (ActiveSupport::Cache::Store): The cache store to monitor

### #read(key, **options)

Reads a value from the cache.

```ruby
value = debugger.read("key")
```

#### Parameters

- `key` (String): The cache key to read
- `**options` (Hash): Additional cache options

#### Returns

- `Object, nil`: The cached value or nil if not found

### #write(key, value, **options)

Writes a value to the cache.

```ruby
debugger.write("key", "value")
```

#### Parameters

- `key` (String): The cache key to write
- `value` (Object): The value to cache
- `**options` (Hash): Additional cache options

#### Returns

- `Boolean`: true if the operation was successful

### #delete(key, **options)

Deletes a value from the cache.

```ruby
debugger.delete("key")
```

#### Parameters

- `key` (String): The cache key to delete
- `**options` (Hash): Additional cache options

#### Returns

- `Boolean`: true if the operation was successful

### #exist?(key, **options)

Checks if a key exists in the cache.

```ruby
debugger.exist?("key")
```

#### Parameters

- `key` (String): The cache key to check
- `**options` (Hash): Additional cache options

#### Returns

- `Boolean`: true if the key exists

### #fetch(key, **options)

Fetches a value from the cache or executes the block if not found.

```ruby
value = debugger.fetch("key") { "default" }
```

#### Parameters

- `key` (String): The cache key to fetch
- `**options` (Hash): Additional cache options
- `&block` (Proc): Block to execute if key is not found

#### Returns

- `Object`: The cached value or the result of the block

## Class Methods

### .log(message)

Logs a message to the console.

```ruby
Rails::Cache::Debugger.log("Cache hit: key")
```

#### Parameters

- `message` (String): The message to log

### .configuration

Returns the current debugger configuration.

```ruby
config = Rails::Cache::Debugger.configuration
```

#### Returns

- `Configuration`: The current configuration instance

## Events

The debugger emits the following events:

- `cache_read.hit`: When a cache read hits
- `cache_read.miss`: When a cache read misses
- `cache_write`: When a value is written to cache
- `cache_delete`: When a value is deleted from cache
- `cache_exist`: When checking if a key exists
- `cache_fetch.hit`: When a cache fetch hits
- `cache_fetch.miss`: When a cache fetch misses

### Event Details

Each event includes the following details:

- `key` (String): The cache key
- `duration` (Float): Operation duration in milliseconds
- `value` (Object): The cached value (for read/write operations)
- `exists` (Boolean): Whether the key exists (for exist? operations)

## Examples

### Basic Usage

```ruby
debugger = Rails::Cache::Debugger.new(Rails.cache)

# Read from cache
value = debugger.read("key")

# Write to cache
debugger.write("key", "value")

# Delete from cache
debugger.delete("key")

# Check if key exists
debugger.exist?("key")

# Fetch with default value
value = debugger.fetch("key") { "default" }
```

### Custom Event Handling

```ruby
Rails::Cache::Debugger.configure do |config|
  config.on_event = ->(event, details) do
    case event
    when "cache_read.hit"
      puts "Cache hit: #{details[:key]}"
    when "cache_read.miss"
      puts "Cache miss: #{details[:key]}"
    end
  end
end
```

### Custom Log Filter

```ruby
Rails::Cache::Debugger.configure do |config|
  config.log_filter = ->(event, details) do
    # Log only slow operations
    details[:duration] > 100
  end
end
```

## Error Handling

The debugger propagates all cache store errors. Common errors include:

- `ActiveSupport::Cache::Store::Error`: Base error class
- `ActiveSupport::Cache::Store::ConnectionError`: Connection errors
- `ActiveSupport::Cache::Store::SerializationError`: Serialization errors

### Example

```ruby
begin
  debugger.read("key")
rescue ActiveSupport::Cache::Store::Error => e
  puts "Cache error: #{e.message}"
end
```

## Performance Considerations

- The debugger adds minimal overhead to cache operations
- Use sampling in production to reduce impact
- Configure appropriate log levels
- Monitor debugger performance

## Best Practices

1. **Configuration**
   - Enable only necessary events
   - Use appropriate log format
   - Configure sampling rate

2. **Error Handling**
   - Handle cache errors appropriately
   - Log errors for debugging
   - Implement fallback strategies

3. **Performance**
   - Monitor debugger impact
   - Use sampling in production
   - Configure appropriate filters

4. **Security**
   - Don't log sensitive data
   - Configure appropriate log levels
   - Monitor resource usage
