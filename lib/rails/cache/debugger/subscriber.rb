# frozen_string_literal: true

module Rails
  module Cache
    class Debugger
      class Subscriber
        def call(name, start, finish, _id, payload)
          return unless configuration.enabled
          return unless configuration.log_events.include?(name)

          key = payload[:key]
          duration = ((finish - start) * 1000).round(2)

          case name
          when "cache_read.active_support"
            hit = payload[:hit]
            Debugger.log "#{hit ? 'HIT' : 'MISS'} key: #{key} (#{duration}ms)"
          when "cache_write.active_support"
            Debugger.log "WRITE key: #{key} (#{duration}ms)"
          when "cache_fetch_hit.active_support"
            Debugger.log "FETCH_HIT key: #{key} (#{duration}ms)"
          end
        end

        private

        def configuration
          Debugger.configuration
        end
      end
    end
  end
end 