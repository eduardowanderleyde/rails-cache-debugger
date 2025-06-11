# frozen_string_literal: true

require "active_support/cache"
require "active_support/notifications"
require "active_support/concern"
require_relative "debugger/configuration"
require_relative "debugger/subscriber"
require_relative "debugger/railtie"
require_relative "debugger/version"

module Rails
  module Cache
    # Main class for debugging Rails cache operations.
    # Provides methods to monitor and log cache operations.
    #
    # @example Basic usage
    #   cache = Rails.cache
    #   debugger = Rails::Cache::Debugger.new(cache)
    #   debugger.read("key")
    #
    # @example Configuration
    #   Rails::Cache::Debugger.configure do |config|
    #     config.enabled = true
    #     config.log_events = ["cache_read.active_support"]
    #   end
    class Debugger
      include ActiveSupport::Configurable

      class << self
        # Logs a message to the configured logger.
        # @param message [String] The message to log
        # @return [void]
        def log(message)
          return unless configuration.enabled

          if configuration.logger
            configuration.logger.info("[CacheDebugger] #{message}")
          else
            puts "[CacheDebugger] #{message}"
          end
        end

        # Returns the current debugger configuration.
        # @return [Configuration] The current configuration instance
        def configuration
          @configuration ||= Configuration.new
        end

        # Configures the debugger with the provided block.
        # @yield [config] The configuration block
        # @yieldparam config [Configuration] The configuration instance
        # @return [void]
        def configure
          yield configuration
        end

        # Returns the current version of the gem.
        # @return [String] The current version
        def version
          VERSION
        end
      end

      # Creates a new debugger instance.
      # @param cache [ActiveSupport::Cache::Store] The cache store to monitor
      # @raise [ArgumentError] If cache is nil
      def initialize(cache)
        raise ArgumentError, "Cache store cannot be nil" if cache.nil?

        @cache = cache
        @subscriber = Subscriber.new
      end

      # Reads a value from the cache and logs the operation.
      # @param key [String] The cache key to read
      # @param **options [Hash] Additional cache options
      # @return [Object, nil] The cached value or nil if not found
      # @raise [ActiveSupport::Cache::Store::Error] If the cache operation fails
      def read(key, **options)
        measure_operation("read", key) do
          value = @cache.read(key, **options)
          log_cache_event(
            event: value.nil? ? "cache_read.miss" : "cache_read.hit",
            key: key,
            value: value
          )
          value
        end
      end

      # Writes a value to the cache and logs the operation.
      # @param key [String] The cache key to write
      # @param value [Object] The value to cache
      # @param **options [Hash] Additional cache options
      # @return [Boolean] true if the operation was successful
      # @raise [ActiveSupport::Cache::Store::Error] If the cache operation fails
      def write(key, value, **options)
        measure_operation("write", key) do
          result = @cache.write(key, value, **options)
          log_cache_event(
            event: "cache_write",
            key: key,
            value: value
          )
          result
        end
      end

      # Deletes a value from the cache and logs the operation.
      # @param key [String] The cache key to delete
      # @param **options [Hash] Additional cache options
      # @return [Boolean] true if the operation was successful
      # @raise [ActiveSupport::Cache::Store::Error] If the cache operation fails
      def delete(key, **options)
        measure_operation("delete", key) do
          result = @cache.delete(key, **options)
          log_cache_event(
            event: "cache_delete",
            key: key
          )
          result
        end
      end

      # Checks if a key exists in the cache and logs the operation.
      # @param key [String] The cache key to check
      # @param **options [Hash] Additional cache options
      # @return [Boolean] true if the key exists
      # @raise [ActiveSupport::Cache::Store::Error] If the cache operation fails
      def exist?(key, **options)
        measure_operation("exist?", key) do
          exists = @cache.exist?(key, **options)
          log_cache_event(
            event: "cache_exist",
            key: key,
            exists: exists
          )
          exists
        end
      end

      # Fetches a value from the cache or executes the block if not found.
      # @param key [String] The cache key to fetch
      # @param **options [Hash] Additional cache options
      # @yield The block to execute if key is not found
      # @return [Object] The cached value or the result of the block
      # @raise [ActiveSupport::Cache::Store::Error] If the cache operation fails
      def fetch(key, **options)
        measure_operation("fetch", key) do
          value = @cache.read(key, **options)
          if value.nil?
            value = yield
            @cache.write(key, value, **options)
            log_cache_event(
              event: "cache_fetch.miss",
              key: key,
              value: value
            )
          else
            log_cache_event(
              event: "cache_fetch.hit",
              key: key,
              value: value
            )
          end
          value
        end
      end

      # Traces all cache operations within the block.
      # @yield The block to trace
      # @return [Object] The result of the block
      def trace
        return yield unless configuration.enabled

        @subscriber.subscribe do
          yield
        end
      end

      private

      # Measures the duration of a cache operation.
      # @param operation [String] The operation name
      # @param key [String] The cache key
      # @yield The operation to measure
      # @return [Object] The result of the operation
      def measure_operation(operation, key)
        return yield unless configuration.enabled

        start_time = Time.now
        result = yield
        duration = ((Time.now - start_time) * 1000).round(2)

        if configuration.sampling_rate.nil? || rand <= configuration.sampling_rate
          log_cache_event(
            event: "cache_#{operation}",
            key: key,
            duration: duration
          )
        end

        result
      rescue ActiveSupport::Cache::Store::Error => e
        log_cache_event(
          event: "cache_#{operation}.error",
          key: key,
          error: e.message
        )
        raise
      end

      # Logs a cache event using ActiveSupport::Notifications.
      # @param event [String] The event name
      # @param key [String] The cache key
      # @param **details [Hash] Additional event details
      # @return [void]
      def log_cache_event(event:, key:, **details)
        return unless configuration.enabled
        return if configuration.log_filter && !configuration.log_filter.call(event, details)

        ActiveSupport::Notifications.instrument(
          "cache_debugger.#{event}",
          { key: key }.merge(details)
        )
      end
    end
  end
end
