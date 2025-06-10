# frozen_string_literal: true

require "active_support/cache"
require "active_support/notifications"
require_relative "debugger/configuration"
require_relative "debugger/subscriber"
require_relative "debugger/railtie"

module Rails
  module Cache
    # Classe principal para debug de operações de cache do Rails.
    # Fornece métodos para monitorar e logar operações de cache.
    #
    # @example Uso básico
    #   cache = Rails.cache
    #   debugger = Rails::Cache::Debugger.new(cache)
    #   debugger.read("key")
    #
    # @example Configuração
    #   Rails::Cache::Debugger.configure do |config|
    #     config.enabled = true
    #     config.log_events = ["cache_read.active_support"]
    #   end
    class Debugger
      class << self
        # Loga uma mensagem no console.
        # @param message [String] A mensagem a ser logada
        # @return [void]
        def log(message)
          puts message
        end

        # Retorna a configuração atual do debugger.
        # @return [Configuration] A instância de configuração
        def configuration
          @configuration ||= Configuration.new
        end

        # Configura o debugger através de um bloco.
        # @yield [config] O bloco de configuração
        # @yieldparam config [Configuration] A instância de configuração
        # @return [void]
        def configure
          yield configuration
        end
      end

      # Inicializa uma nova instância do debugger.
      # @param cache [ActiveSupport::Cache::Store] A instância do cache a ser monitorada
      def initialize(cache)
        @cache = cache
      end

      # Lê um valor do cache e loga a operação.
      # @param key [String] A chave a ser lida
      # @param **options [Hash] Opções adicionais para a operação de cache
      # @return [Object, nil] O valor lido do cache ou nil se não encontrado
      # @example
      #   debugger.read("user:1")
      #   # => [CacheDebugger] HIT key: user:1 (0.45ms)
      def read(key, **)
        start_time = Time.now
        value = @cache.read(key, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(
          event: value.nil? ? "cache_read.miss" : "cache_read.hit",
          key: key,
          value: value,
          duration: duration
        )
        value
      end

      # Escreve um valor no cache e loga a operação.
      # @param key [String] A chave a ser escrita
      # @param value [Object] O valor a ser armazenado
      # @param **options [Hash] Opções adicionais para a operação de cache
      # @return [Boolean] true se a operação foi bem sucedida
      # @example
      #   debugger.write("user:1", { name: "John" })
      #   # => [CacheDebugger] WRITE key: user:1 (0.67ms)
      def write(key, value, **)
        start_time = Time.now
        result = @cache.write(key, value, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(
          event: "cache_write",
          key: key,
          value: value,
          duration: duration
        )
        result
      end

      # Remove um valor do cache e loga a operação.
      # @param key [String] A chave a ser removida
      # @param **options [Hash] Opções adicionais para a operação de cache
      # @return [Boolean] true se a operação foi bem sucedida
      # @example
      #   debugger.delete("user:1")
      #   # => [CacheDebugger] DELETE key: user:1 (0.34ms)
      def delete(key, **)
        start_time = Time.now
        result = @cache.delete(key, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(
          event: "cache_delete",
          key: key,
          duration: duration
        )
        result
      end

      # Verifica se uma chave existe no cache e loga a operação.
      # @param key [String] A chave a ser verificada
      # @param **options [Hash] Opções adicionais para a operação de cache
      # @return [Boolean] true se a chave existe
      # @example
      #   debugger.exist?("user:1")
      #   # => [CacheDebugger] EXIST key: user:1 (0.23ms)
      def exist?(key, **)
        start_time = Time.now
        exists = @cache.exist?(key, **)
        duration = ((Time.now - start_time) * 1000).round(2)
        log_cache_event(
          event: "cache_exist",
          key: key,
          exists: exists,
          duration: duration
        )
        exists
      end

      # Busca um valor do cache ou executa o bloco se não encontrado.
      # @param key [String] A chave a ser buscada
      # @param **options [Hash] Opções adicionais para a operação de cache
      # @yield O bloco a ser executado se a chave não for encontrada
      # @return [Object] O valor do cache ou o resultado do bloco
      # @example
      #   debugger.fetch("user:1") { User.find(1) }
      #   # => [CacheDebugger] FETCH_HIT key: user:1 (0.45ms)
      def fetch(key, **)
        start_time = Time.now
        value = @cache.read(key, **)
        if value.nil?
          value = yield
          @cache.write(key, value, **)
          duration = ((Time.now - start_time) * 1000).round(2)
          log_cache_event(
            event: "cache_fetch.miss",
            key: key,
            value: value,
            duration: duration
          )
        else
          duration = ((Time.now - start_time) * 1000).round(2)
          log_cache_event(
            event: "cache_fetch.hit",
            key: key,
            value: value,
            duration: duration
          )
        end
        value
      end

      private

      # Loga um evento de cache usando ActiveSupport::Notifications.
      # @param event [String] O nome do evento
      # @param key [String] A chave do cache
      # @param **details [Hash] Detalhes adicionais do evento
      # @return [void]
      def log_cache_event(event:, key:, **details)
        ActiveSupport::Notifications.instrument(
          "cache_debugger.#{event}",
          { key: key }.merge(details)
        )
      end
    end
  end
end
