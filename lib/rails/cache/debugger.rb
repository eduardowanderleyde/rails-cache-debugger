# lib/rails/cache/debugger.rb
# frozen_string_literal: true

require "active_support/cache"
require "active_support/notifications"
require_relative "debugger/configuration"
require_relative "debugger/subscriber"
require_relative "debugger/railtie"
require_relative "debugger/version"

module Rails
  module Cache
    class Debugger
      # Returns the current debugger configuration
      def self.configuration
        @configuration ||= Configuration.new
      end

      # Configure the debugger
      def self.configure
        yield configuration
      end

      # Logs a message using the configured logger
      def self.log(message)
        return unless configuration.enabled

        logger = configuration.logger
        if logger.respond_to?(:call)
          logger.call(message)
        elsif logger.respond_to?(:info)
          logger.info(message)
        else
          puts message
        end
      end

      # Initialize debugger with a cache store and optional logger
      def initialize(store, logger: nil)
        raise ArgumentError, "Cache store cannot be nil" if store.nil?

        @store = store
        self.class.configuration.logger  = logger if logger
        self.class.configuration.enabled = true
        @subscriber = Subscriber.new

        # Subscribe to ActiveSupport cache events for formatting
        ActiveSupport::Notifications.subscribe("cache_write.active_support", @subscriber)
        ActiveSupport::Notifications.subscribe("cache_read.active_support", @subscriber)
        ActiveSupport::Notifications.subscribe("cache_delete.active_support", @subscriber)
        ActiveSupport::Notifications.subscribe("cache_exist.active_support", @subscriber)
        ActiveSupport::Notifications.subscribe("cache_fetch_hit.active_support", @subscriber)
        ActiveSupport::Notifications.subscribe("cache_fetch_miss.active_support", @subscriber)
      end

      # Reads a value and logs the operation
      def read(key, **)
        start_time = Time.now
        value = @store.read(key, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        event = value.nil? ? "cache_read.miss" : "cache_read.hit"
        log_cache_event(event: event, key: key, value: value, duration: duration)
        value
      end

      # Writes a value and logs the operation
      def write(key, value, **)
        start_time = Time.now
        result = @store.write(key, value, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(event: "cache_write", key: key, value: value, duration: duration)
        result
      end

      # Deletes a value and logs the operation
      def delete(key, **)
        start_time = Time.now
        result = @store.delete(key, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(event: "cache_delete", key: key, duration: duration)
        result
      end

      # Checks existence and logs the operation
      def exist?(key, **)
        start_time = Time.now
        exists = @store.exist?(key, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(event: "cache_exist", key: key, exists: exists, duration: duration)
        exists
      end

      # Fetches or computes and logs the operation
      def fetch(key, **, &block)
        start_time = Time.now
        value = @store.read(key, **)
        if value.nil?
          value = block.call if block
          @store.write(key, value, **)
          event = "cache_fetch.miss"
        else
          event = "cache_fetch.hit"
        end
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(event: event, key: key, value: value, duration: duration)
        value
      end

      private

      # Instruments and records cache events (debugger events)
      def log_cache_event(event:, key:, **details)
        return unless self.class.configuration.enabled

        ActiveSupport::Notifications.instrument(
          "cache_debugger.#{event}",
          { key: key }.merge(details.except(:duration))
        )
      end
    end
  end
end
