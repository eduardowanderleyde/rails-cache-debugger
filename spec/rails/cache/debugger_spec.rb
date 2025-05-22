# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rails::Cache::Debugger do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:debugger) { described_class.new(cache) }

  describe "#read" do
    it "logs cache miss when key doesn't exist" do
      expect(debugger).to receive(:log_cache_event).with(
        event: "cache_read.miss",
        key: "test_key",
        value: nil,
        duration: kind_of(Float)
      )

      debugger.read("test_key")
    end

    it "logs cache hit when key exists" do
      cache.write("test_key", "test_value")
      
      expect(debugger).to receive(:log_cache_event).with(
        event: "cache_read.hit",
        key: "test_key",
        value: "test_value",
        duration: kind_of(Float)
      )

      debugger.read("test_key")
    end
  end

  describe "#write" do
    it "logs cache write event" do
      expect(debugger).to receive(:log_cache_event).with(
        event: "cache_write",
        key: "test_key",
        value: "test_value",
        duration: kind_of(Float)
      )

      debugger.write("test_key", "test_value")
    end
  end

  describe "#delete" do
    it "logs cache delete event" do
      expect(debugger).to receive(:log_cache_event).with(
        event: "cache_delete",
        key: "test_key",
        duration: kind_of(Float)
      )

      debugger.delete("test_key")
    end
  end

  describe "#exist?" do
    it "logs cache exist check" do
      expect(debugger).to receive(:log_cache_event).with(
        event: "cache_exist",
        key: "test_key",
        exists: false,
        duration: kind_of(Float)
      )

      debugger.exist?("test_key")
    end
  end

  describe "#fetch" do
    it "logs cache fetch hit" do
      cache.write("test_key", "test_value")
      
      expect(debugger).to receive(:log_cache_event).with(
        event: "cache_fetch.hit",
        key: "test_key",
        value: "test_value",
        duration: kind_of(Float)
      )

      debugger.fetch("test_key") { "new_value" }
    end

    it "logs cache fetch miss and executes block" do
      expect(debugger).to receive(:log_cache_event).with(
        event: "cache_fetch.miss",
        key: "test_key",
        value: "new_value",
        duration: kind_of(Float)
      )

      result = debugger.fetch("test_key") { "new_value" }
      expect(result).to eq("new_value")
    end
  end
end

RSpec.describe Rails::Cache::Debugger::Subscriber do
  let(:subscriber) { described_class.new }
  let(:start_time) { Time.now }
  let(:end_time) { start_time + 0.00123 } # 1.23ms

  it "formats cache read hit" do
    expect(Rails::Cache::Debugger).to receive(:log).with(
      "HIT key: test_key (1.23ms)"
    )

    subscriber.call(
      "cache_read.active_support",
      start_time,
      end_time,
      "id",
      { key: "test_key", hit: true }
    )
  end

  it "formats cache read miss" do
    expect(Rails::Cache::Debugger).to receive(:log).with(
      "MISS key: test_key (1.23ms)"
    )

    subscriber.call(
      "cache_read.active_support",
      start_time,
      end_time,
      "id",
      { key: "test_key", hit: false }
    )
  end

  it "formats cache write" do
    expect(Rails::Cache::Debugger).to receive(:log).with(
      "WRITE key: test_key (1.23ms)"
    )

    subscriber.call(
      "cache_write.active_support",
      start_time,
      end_time,
      "id",
      { key: "test_key" }
    )
  end

  it "formats cache fetch hit" do
    expect(Rails::Cache::Debugger).to receive(:log).with(
      "FETCH_HIT key: test_key (1.23ms)"
    )

    subscriber.call(
      "cache_fetch_hit.active_support",
      start_time,
      end_time,
      "id",
      { key: "test_key" }
    )
  end
end

RSpec.describe Rails::Cache::Debugger::Configuration do
  let(:config) { described_class.new }

  it "has default values" do
    expect(config.enabled).to be true
    expect(config.log_events).to match_array([
      "cache_read.active_support",
      "cache_write.active_support",
      "cache_fetch_hit.active_support"
    ])
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
