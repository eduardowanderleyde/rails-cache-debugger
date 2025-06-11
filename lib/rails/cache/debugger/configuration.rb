# frozen_string_literal: true

require "logger"

module Rails
  module Cache
    class Debugger
      # Configuration class for the Rails Cache Debugger.
      # Handles all configuration options and their defaults.
      class Configuration
        # @return [Boolean] Whether the debugger is enabled
        attr_accessor :enabled

        # @return [Array<String>] List of events to log
        attr_accessor :log_events

        # @return [Symbol] Log format (:text or :json)
        attr_accessor :log_format

        # @return [Float] Rate of operations to log (0.0 to 1.0)
        attr_accessor :sampling_rate

        # @return [Proc] Custom filter for log events
        attr_accessor :log_filter

        # @return [Proc] Custom event handler
        attr_accessor :on_event

        # @return [Logger] Logger instance
        attr_accessor :logger

        # Creates a new configuration instance with default values.
        def initialize
          @enabled = true
          @log_events = [
            "cache_read.active_support",
            "cache_write.active_support",
            "cache_fetch_hit.active_support"
          ]
          @log_format = :text
          @sampling_rate = nil
          @log_filter = nil
          @on_event = nil
          @logger = nil
        end

        # Validates the configuration.
        # @raise [ArgumentError] If the configuration is invalid
        def validate!
          validate_log_format!
          validate_sampling_rate!
          validate_log_filter!
          validate_on_event!
        end

        private

        # Validates the log format.
        # @raise [ArgumentError] If the log format is invalid
        def validate_log_format!
          return if %i[text json].include?(@log_format)

          raise ArgumentError, "Log format must be :text or :json"
        end

        # Validates the sampling rate.
        # @raise [ArgumentError] If the sampling rate is invalid
        def validate_sampling_rate!
          return if @sampling_rate.nil?
          return if @sampling_rate.between?(0.0, 1.0)

          raise ArgumentError, "Sampling rate must be between 0.0 and 1.0"
        end

        # Validates the log filter.
        # @raise [ArgumentError] If the log filter is invalid
        def validate_log_filter!
          return if @log_filter.nil?
          return if @log_filter.respond_to?(:call)

          raise ArgumentError, "Log filter must respond to #call"
        end

        # Validates the event handler.
        # @raise [ArgumentError] If the event handler is invalid
        def validate_on_event!
          return if @on_event.nil?
          return if @on_event.respond_to?(:call)

          raise ArgumentError, "Event handler must respond to #call"
        end
      end
    end
  end
end
