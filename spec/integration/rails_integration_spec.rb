# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rails::Cache::Debugger integration', type: :request do
  before(:all) do
    # Define um controller de teste no dummy
    class ::CacheTestController < ActionController::Base
      def write
        Rails.cache.write('foo', 'bar')
        render plain: 'ok'
      end
      def read
        value = Rails.cache.read('foo')
        render plain: value || 'nil'
      end
    end

    Rails.application.routes.draw do
      get '/cache_write', to: 'cache_test#write'
      get '/cache_read', to: 'cache_test#read'
    end
  end

  it 'logs cache write and read events' do
    logs = []
    allow(Rails::Cache::Debugger).to receive(:log) { |msg| logs << msg }

    get '/cache_write'
    get '/cache_read'

    expect(logs.any? { |msg| msg.include?('WRITE key: foo') }).to be true
    expect(logs.any? { |msg| msg.include?('HIT key: foo') }).to be true
  end
end 