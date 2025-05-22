# frozen_string_literal: true

require "rails"

module Rails
  module Cache
    class Debugger
      class Railtie < Rails::Railtie
        initializer "rails-cache-debugger.setup" do
          subscriber = Subscriber.new

          %w[
            cache_read.active_support
            cache_write.active_support
            cache_fetch_hit.active_support
          ].each do |event|
            ActiveSupport::Notifications.subscribe(event, subscriber)
          end
        end
      end
    end
  end
end 