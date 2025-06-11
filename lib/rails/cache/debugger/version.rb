# frozen_string_literal: true

module Rails
  module Cache
    class Debugger
      # Version information for the Rails Cache Debugger gem.
      # Follows Semantic Versioning (https://semver.org/).
      module Version
        # Major version number.
        # Incremented for incompatible API changes.
        MAJOR = 0

        # Minor version number.
        # Incremented for backwards-compatible functionality.
        MINOR = 1

        # Patch version number.
        # Incremented for backwards-compatible bug fixes.
        PATCH = 0

        # Pre-release version.
        # Set to nil for stable releases.
        PRE = nil

        # Build metadata.
        # Set to nil for stable releases.
        BUILD = nil

        # Returns the version string.
        # @return [String] The version string
        def self.to_s
          version = [MAJOR, MINOR, PATCH].join(".")
          version = "#{version}-#{PRE}" if PRE
          version = "#{version}+#{BUILD}" if BUILD
          version
        end

        # Returns the version array.
        # @return [Array<Integer>] The version array
        def self.to_a
          [MAJOR, MINOR, PATCH]
        end

        # Returns the version hash.
        # @return [Hash<Symbol, Object>] The version hash
        def self.to_h
          {
            major: MAJOR,
            minor: MINOR,
            patch: PATCH,
            pre: PRE,
            build: BUILD
          }
        end
      end

      # Returns the current version of the gem.
      # @return [String] The version string
      def self.version
        Version.to_s
      end
    end
  end
end
