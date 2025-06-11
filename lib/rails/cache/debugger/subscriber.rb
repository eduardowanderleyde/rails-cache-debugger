# lib/rails/cache/debugger/subscriber.rb
# frozen_string_literal: true

require "active_support/notifications"

module Rails
  module Cache
    class Debugger
      # Subscriber for both ActiveSupport and debugger notifications
      class Subscriber
        def initialize
          @subscriptions = []
        end

        # Integration: subscribe to debugger instrumented events
        def subscribe
          events = %w[
            cache_debugger.cache_write
            cache_debugger.cache_read.miss
            cache_debugger.cache_read.hit
            cache_debugger.cache_delete
            cache_debugger.cache_exist
            cache_debugger.cache_fetch.miss
            cache_debugger.cache_fetch.hit
          ]
          events.each do |event|
            sub = ActiveSupport::Notifications.subscribe(event) do |name, _st, _fn, _id, payload|
              # Determine type: last segment or after 'cache_'
              raw = name.split(".").last
              raw = raw.sub(/^cache_/, "")
              type = raw.upcase
              Debugger.log("#{type} key: #{payload[:key]}")
            end
            @subscriptions << sub
          end
          yield
        ensure
          @subscriptions.each { |sub| ActiveSupport::Notifications.unsubscribe(sub) }
          @subscriptions.clear
        end

        # Formatting: handle ActiveSupport cache events
        def call(name, start_time, end_time, _id, payload)
          return unless Debugger.configuration.enabled

          duration = ((end_time - start_time) * 1000).round(2)
          type = case name
                 when "cache_read.active_support"
                   payload.fetch(:hit, false) ? "HIT" : "MISS"
                 when "cache_write.active_support"
                   "WRITE"
                 when "cache_delete.active_support"
                   "DELETE"
                 when "cache_exist.active_support"
                   "EXIST"
                 when "cache_fetch_hit.active_support"
                   "FETCH_HIT"
                 when "cache_fetch_miss.active_support"
                   "FETCH_MISS"
                 else
                   return
                 end
          Debugger.log("#{type} key: #{payload[:key]} (#{duration}ms)")
        end
      end
    end
  end
end
