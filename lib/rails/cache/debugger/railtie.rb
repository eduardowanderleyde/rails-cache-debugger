# frozen_string_literal: true

require "rails/railtie"
require_relative "configuration"

module Rails
  module Cache
    class Debugger
      # Railtie for integrating the debugger with Rails.
      # Handles initialization and configuration of the debugger.
      class Railtie < ::Rails::Railtie
        # Initializes the debugger when the application starts.
        # @return [void]
        initializer "rails_cache_debugger.configure" do |app|
          # Configure the debugger
          configuration = Configuration.new

          # Set default logger
          configuration.logger = Rails.logger

          # Set default log format based on Rails environment
          configuration.log_format = Rails.env.production? ? :json : :text

          # Set default sampling rate based on Rails environment
          configuration.sampling_rate = Rails.env.production? ? 0.1 : 1.0

          # Set default log events
          configuration.log_events = %w[
            cache_read.active_support
            cache_write.active_support
            cache_delete.active_support
            cache_exist.active_support
            cache_fetch_hit.active_support
            cache_fetch_miss.active_support
          ]

          # Set default log filter
          configuration.log_filter = lambda do |event, details|
            return false if details[:key].to_s.start_with?("_")
            return false if details[:duration] < 1 # Ignore very fast operations
            true
          end

          # Set default event handler
          configuration.on_event = lambda do |event, details|
            # You can add custom event handling here
            # For example, sending events to a monitoring service
          end

          # Apply configuration
          Debugger.configure do |config|
            config.enabled = configuration.enabled
            config.logger = configuration.logger
            config.log_format = configuration.log_format
            config.sampling_rate = configuration.sampling_rate
            config.log_events = configuration.log_events
            config.log_filter = configuration.log_filter
            config.on_event = configuration.on_event
          end

          # Validate configuration
          configuration.validate!
        end

        # Subscribes to cache events when the application starts.
        # @return [void]
        config.after_initialize do
          if Debugger.configuration.enabled
            subscriber = Subscriber.new
            subscriber.subscribe do
              # The subscriber will be active for the duration of the block
              # This is a no-op block as the subscriber is managed by ActiveSupport::Notifications
            end
          end
        end
      end
    end
  end
end
