# Advanced Usage of Rails Cache Debugger

This document describes advanced features and use cases of the Rails Cache Debugger.

## APM Integration

The Rails Cache Debugger can be integrated with APM (Application Performance Monitoring) tools like New Relic, Datadog, or Scout.

```ruby
# config/initializers/cache_debugger.rb
Rails::Cache::Debugger.configure do |config|
  config.enabled = true
  
  # New Relic Integration
  config.on_event = ->(event, details) do
    NewRelic::Agent.record_custom_event(
      "CacheOperation",
      details.merge(event: event)
    )
  end
end
```

## Custom Metrics

You can collect custom metrics about cache usage:

```ruby
class CacheMetrics
  def self.record_metric(name, value)
    # Implement your metrics logic here
    StatsD.gauge("cache.#{name}", value)
  end
end

Rails::Cache::Debugger.configure do |config|
  config.on_event = ->(event, details) do
    case event
    when "cache_read.hit"
      CacheMetrics.record_metric("hits", 1)
    when "cache_read.miss"
      CacheMetrics.record_metric("misses", 1)
    end
  end
end
```

## Advanced Logging

### JSON Format

```ruby
Rails::Cache::Debugger.configure do |config|
  config.log_format = :json
  config.logger = Logger.new("log/cache.log")
end
```

### Log Filters

```ruby
Rails::Cache::Debugger.configure do |config|
  config.log_filter = ->(event, details) do
    # Log only operations that take more than 100ms
    details[:duration] > 100
  end
end
```

## Performance

### Log Optimization

For production environments, you can optimize logging:

```ruby
Rails::Cache::Debugger.configure do |config|
  config.enabled = Rails.env.development?
  config.log_events = ["cache_read.active_support"] if Rails.env.production?
  config.log_format = :json if Rails.env.production?
end
```

### Sampling

```ruby
Rails::Cache::Debugger.configure do |config|
  config.sampling_rate = 0.1 # Log only 10% of operations
end
```

## Advanced Debugging

### Operation Tracing

```ruby
debugger = Rails::Cache::Debugger.new(Rails.cache)

debugger.trace do
  # All cache operations in this block will be logged
  User.find(1)
  Post.find(1)
end
```

### Pattern Analysis

```ruby
class CachePatternAnalyzer
  def initialize
    @patterns = Hash.new(0)
  end

  def analyze(event, details)
    key = details[:key]
    pattern = extract_pattern(key)
    @patterns[pattern] += 1
  end

  private

  def extract_pattern(key)
    # Implement your pattern extraction logic
    key.split(":").first
  end
end

analyzer = CachePatternAnalyzer.new
Rails::Cache::Debugger.configure do |config|
  config.on_event = ->(event, details) { analyzer.analyze(event, details) }
end
```

## Test Integration

### Performance Tests

```ruby
RSpec.describe "Cache Performance" do
  it "performs cache operations within acceptable time" do
    debugger = Rails::Cache::Debugger.new(Rails.cache)
    
    expect {
      debugger.read("test_key")
    }.to take_less_than(100).ms
  end
end
```

### Integration Tests

```ruby
RSpec.describe "Cache Integration" do
  it "logs all cache operations" do
    debugger = Rails::Cache::Debugger.new(Rails.cache)
    logs = []
    
    Rails::Cache::Debugger.configure do |config|
      config.on_event = ->(event, details) { logs << [event, details] }
    end
    
    debugger.write("key", "value")
    debugger.read("key")
    
    expect(logs).to include(
      ["cache_write", hash_including(key: "key")],
      ["cache_read.hit", hash_including(key: "key")]
    )
  end
end
```

## Advanced Troubleshooting

### Problem Diagnosis

1. **Inconsistent Cache**

   ```ruby
   debugger = Rails::Cache::Debugger.new(Rails.cache)
   
   # Check if value is in cache
   debugger.exist?("problematic_key")
   
   # Check current value
   debugger.read("problematic_key")
   
   # Force an update
   debugger.write("problematic_key", "new_value")
   ```

2. **Performance Degradation**

   ```ruby
   # Configure debugger to log only slow operations
   Rails::Cache::Debugger.configure do |config|
     config.log_filter = ->(event, details) do
       details[:duration] > 100 # Log only operations > 100ms
     end
   end
   ```

### Production Monitoring

```ruby
# config/initializers/cache_debugger.rb
if Rails.env.production?
  Rails::Cache::Debugger.configure do |config|
    config.enabled = true
    config.log_events = ["cache_read.active_support"]
    config.sampling_rate = 0.01 # 1% of operations
    config.on_event = ->(event, details) do
      if details[:duration] > 1000 # 1 second
        ErrorReporting.notify(
          "Slow cache operation",
          event: event,
          details: details
        )
      end
    end
  end
end
```

## Best Practices

1. **Environment Configuration**
   - Development: Full logging
   - Test: Minimal logging
   - Production: Selective logging

2. **Monitoring**
   - Configure alerts for slow operations
   - Monitor usage patterns
   - Track important metrics

3. **Performance**
   - Use sampling in production
   - Configure appropriate filters
   - Monitor debugger impact

4. **Security**
   - Don't log sensitive data
   - Configure appropriate log levels
   - Monitor resource usage
