# frozen_string_literal: true

require "active_support/cache"
require "active_support/notifications"
require_relative "debugger/configuration"
require_relative "debugger/subscriber"
require_relative "debugger/railtie"

module Rails
  module Cache
    class Debugger
      class << self
        def log(message)
          puts message
        end

        def configuration
          @configuration ||= Configuration.new
        end

        def configure
          yield configuration
        end
      end

      def initialize(cache)
        @cache = cache
      end

      def read(key, **)
        start_time = Time.now
        value = @cache.read(key, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(
          event: value.nil? ? "cache_read.miss" : "cache_read.hit",
          key: key,
          value: value,
          duration: duration
        )
        value
      end

      def write(key, value, **)
        start_time = Time.now
        result = @cache.write(key, value, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(
          event: "cache_write",
          key: key,
          value: value,
          duration: duration
        )
        result
      end

      def delete(key, **)
        start_time = Time.now
        result = @cache.delete(key, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(
          event: "cache_delete",
          key: key,
          duration: duration
        )
        result
      end

      def exist?(key, **)
        start_time = Time.now
        exists = @cache.exist?(key, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(
          event: "cache_exist",
          key: key,
          exists: exists,
          duration: duration
        )
        exists
      end

      def fetch(key, **)
        start_time = Time.now
        value = @cache.read(key, **)
        if value.nil?
          value = yield
          @cache.write(key, value, **)
          duration = ((Time.now - start_time) * 1000).round(2)
          log_cache_event(
            event: "cache_fetch.miss",
            key: key,
            value: value,
            duration: duration
          )
        else
          duration = ((Time.now - start_time) * 1000).round(2)
          log_cache_event(
            event: "cache_fetch.hit",
            key: key,
            value: value,
            duration: duration
          )
        end
        value
      end

      private

      def log_cache_event(event:, key:, **details)
        ActiveSupport::Notifications.instrument(
          "cache_debugger.#{event}",
          { key: key }.merge(details)
        )
      end
    end
  end
end
