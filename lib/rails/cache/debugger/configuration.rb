# frozen_string_literal: true

module Rails
  module Cache
    class Debugger
      class Configuration
        attr_accessor :enabled, :log_events

        def initialize
          @enabled = true
          @log_events = %w[
            cache_read.active_support
            cache_write.active_support
            cache_fetch_hit.active_support
          ]
        end
      end
    end
  end
end 