# frozen_string_literal: true

require_relative "lib/rails/cache/debugger/version"

Gem::Specification.new do |spec|
  spec.name = "rails-cache-debugger"
  spec.version = Rails::Cache::Debugger::VERSION
  spec.authors = ["Eduardo Wanderley de Siqueira Araújo"]
  spec.email = ["wanderley.eduardo@gmail.com"]

  spec.summary = "A gem to help debug Rails cache operations"
  spec.description = "Provides visibility into Rails cache operations by logging cache hits, misses, writes, "
  spec.description += "and deletes"
  spec.homepage = "https://github.com/yourusername/rails-cache-debugger"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob("lib/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 6.0.0"
  spec.add_dependency "railties", ">= 6.0.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-rspec", "~> 2.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
