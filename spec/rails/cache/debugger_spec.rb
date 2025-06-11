# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rails::Cache::Debugger do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:debugger) { described_class.new(cache) }

  before do
    allow(debugger).to receive(:log_cache_event)
  end

  describe "#read" do
    it "logs cache miss when key doesn't exist" do
      debugger.read("test_key")
      expect(debugger).to have_received(:log_cache_event).with(
        event: "cache_read.miss",
        key: "test_key",
        value: nil,
        duration: kind_of(Float)
      )
    end

    it "logs cache hit when key exists" do
      cache.write("test_key", "test_value")
      debugger.read("test_key")
      expect(debugger).to have_received(:log_cache_event).with(
        event: "cache_read.hit",
        key: "test_key",
        value: "test_value",
        duration: kind_of(Float)
      )
    end
  end

  describe "#write" do
    it "logs cache write event" do
      debugger.write("test_key", "test_value")
      expect(debugger).to have_received(:log_cache_event).with(
        event: "cache_write",
        key: "test_key",
        value: "test_value",
        duration: kind_of(Float)
      )
    end
  end

  describe "#delete" do
    it "logs cache delete event" do
      debugger.delete("test_key")
      expect(debugger).to have_received(:log_cache_event).with(
        event: "cache_delete",
        key: "test_key",
        duration: kind_of(Float)
      )
    end
  end

  describe "#exist?" do
    it "logs cache exist check" do
      debugger.exist?("test_key")
      expect(debugger).to have_received(:log_cache_event).with(
        event: "cache_exist",
        key: "test_key",
        exists: false,
        duration: kind_of(Float)
      )
    end
  end

  describe "#fetch" do
    it "logs cache fetch hit" do
      cache.write("test_key", "test_value")
      debugger.fetch("test_key") { "new_value" }
      expect(debugger).to have_received(:log_cache_event).with(
        event: "cache_fetch.hit",
        key: "test_key",
        value: "test_value",
        duration: kind_of(Float)
      )
    end

    it "logs cache fetch miss and executes block" do
      result = debugger.fetch("test_key") { "new_value" }
      expect(result).to eq("new_value")
      expect(debugger).to have_received(:log_cache_event).with(
        event: "cache_fetch.miss",
        key: "test_key",
        value: "new_value",
        duration: kind_of(Float)
      )
    end
  end

  context "when the cache store raises an exception" do
    let(:broken_cache) do
      Class.new do
        def read(*)
          raise "Cache unavailable"
        end

        def write(*)
          raise "Cache unavailable"
        end

        def delete(*)
          raise "Cache unavailable"
        end

        def exist?(*)
          raise "Cache unavailable"
        end

        def fetch(*)
          raise "Cache unavailable"
        end
      end.new
    end
    let(:debugger) { described_class.new(broken_cache) }

    it "propagates exception on read" do
      expect { debugger.read("key") }.to raise_error("Cache unavailable")
    end

    it "propagates exception on write" do
      expect { debugger.write("key", "value") }.to raise_error("Cache unavailable")
    end

    it "propagates exception on delete" do
      expect { debugger.delete("key") }.to raise_error("Cache unavailable")
    end

    it "propagates exception on exist?" do
      expect { debugger.exist?("key") }.to raise_error("Cache unavailable")
    end

    it "propagates exception on fetch" do
      expect { debugger.fetch("key") { "value" } }.to raise_error("Cache unavailable")
    end
  end
end

RSpec.describe Rails::Cache::Debugger::Subscriber do
  let(:subscriber) { described_class.new }
  let(:start_time) { Time.now }
  let(:end_time) { start_time + 0.00123 } # 1.23ms

  before do
    allow(Rails::Cache::Debugger).to receive(:log)
  end

  it "formats cache read hit" do
    subscriber.call(
      "cache_read.active_support",
      start_time,
      end_time,
      "id",
      { key: "test_key", hit: true }
    )
    expect(Rails::Cache::Debugger).to have_received(:log).with(
      "HIT key: test_key (1.23ms)"
    )
  end

  it "formats cache read miss" do
    subscriber.call(
      "cache_read.active_support",
      start_time,
      end_time,
      "id",
      { key: "test_key", hit: false }
    )
    expect(Rails::Cache::Debugger).to have_received(:log).with(
      "MISS key: test_key (1.23ms)"
    )
  end

  it "formats cache write" do
    subscriber.call(
      "cache_write.active_support",
      start_time,
      end_time,
      "id",
      { key: "test_key" }
    )
    expect(Rails::Cache::Debugger).to have_received(:log).with(
      "WRITE key: test_key (1.23ms)"
    )
  end

  it "formats cache fetch hit" do
    subscriber.call(
      "cache_fetch_hit.active_support",
      start_time,
      end_time,
      "id",
      { key: "test_key" }
    )
    expect(Rails::Cache::Debugger).to have_received(:log).with(
      "FETCH_HIT key: test_key (1.23ms)"
    )
  end
end

RSpec.describe Rails::Cache::Debugger::Configuration do
  let(:config) { described_class.new }

  it "has default values" do
    expect(config.enabled).to be true
    expect(config.log_events).to contain_exactly("cache_read.active_support", "cache_write.active_support",
                                                 "cache_fetch_hit.active_support")
  end

  it "allows customizing log events" do
    config.log_events = ["custom_event"]
    expect(config.log_events).to eq(["custom_event"])
  end

  it "allows disabling the debugger" do
    config.enabled = false
    expect(config.enabled).to be false
  end
end
