# frozen_string_literal: true

require "active_support/notifications"

module Rails
  module Cache
    class Debugger
      # Subscriber class for handling cache events.
      # Manages event subscriptions and notifications.
      class Subscriber
        # Creates a new subscriber instance.
        def initialize
          @subscribers = []
        end

        # Subscribes to cache events within the block.
        # @yield The block to execute while subscribed
        # @return [Object] The result of the block
        def subscribe
          subscribe_to_events
          yield
        ensure
          unsubscribe_from_events
        end

        private

        # Subscribes to all configured cache events.
        # @return [void]
        def subscribe_to_events
          Rails::Cache::Debugger.configuration.log_events.each do |event|
            subscriber = ActiveSupport::Notifications.subscribe(event) do |*args|
              handle_event(event, *args)
            end
            @subscribers << subscriber
          end
        end

        # Unsubscribes from all cache events.
        # @return [void]
        def unsubscribe_from_events
          @subscribers.each do |subscriber|
            ActiveSupport::Notifications.unsubscribe(subscriber)
          end
          @subscribers.clear
        end

        # Handles a cache event.
        # @param event [String] The event name
        # @param start_time [Time] The start time of the event
        # @param end_time [Time] The end time of the event
        # @param id [String] The event ID
        # @param payload [Hash] The event payload
        # @return [void]
        def handle_event(event, start_time, end_time, id, payload)
          return unless Rails::Cache::Debugger.configuration.enabled

          duration = ((end_time - start_time) * 1000).round(2)
          details = payload.merge(duration: duration)

          if Rails::Cache::Debugger.configuration.on_event
            Rails::Cache::Debugger.configuration.on_event.call(event, details)
          end

          log_event(event, details)
        end

        # Logs a cache event.
        # @param event [String] The event name
        # @param details [Hash] The event details
        # @return [void]
        def log_event(event, details)
          return if Rails::Cache::Debugger.configuration.log_filter &&
                   !Rails::Cache::Debugger.configuration.log_filter.call(event, details)

          message = format_event_message(event, details)
          Rails::Cache::Debugger.log(message)
        end

        # Formats an event message.
        # @param event [String] The event name
        # @param details [Hash] The event details
        # @return [String] The formatted message
        def format_event_message(event, details)
          case Rails::Cache::Debugger.configuration.log_format
          when :json
            format_json_message(event, details)
          else
            format_text_message(event, details)
          end
        end

        # Formats a JSON event message.
        # @param event [String] The event name
        # @param details [Hash] The event details
        # @return [String] The formatted JSON message
        def format_json_message(event, details)
          require "json"
          {
            event: event,
            timestamp: Time.now.iso8601,
            details: details
          }.to_json
        end

        # Formats a text event message.
        # @param event [String] The event name
        # @param details [Hash] The event details
        # @return [String] The formatted text message
        def format_text_message(event, details)
          key = details[:key]
          duration = details[:duration]
          type = event.split(".").last.upcase

          case type
          when "HIT"
            "HIT key: #{key} (#{duration}ms)"
          when "MISS"
            "MISS key: #{key} (#{duration}ms)"
          when "WRITE"
            "WRITE key: #{key} (#{duration}ms)"
          when "DELETE"
            "DELETE key: #{key} (#{duration}ms)"
          when "EXIST"
            exists = details[:exists]
            "EXIST key: #{key} (#{exists}) (#{duration}ms)"
          when "FETCH_HIT"
            "FETCH_HIT key: #{key} (#{duration}ms)"
          when "FETCH_MISS"
            "FETCH_MISS key: #{key} (#{duration}ms)"
          else
            "#{type} key: #{key} (#{duration}ms)"
          end
        end
      end
    end
  end
end
