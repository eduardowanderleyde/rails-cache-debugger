# frozen_string_literal: true

require_relative "lib/rails/cache/debugger/version"

Gem::Specification.new do |spec|
  spec.name = "rails-cache-debugger"
  spec.version = Rails::Cache::Debugger::Version.to_s
  spec.authors = ["Your Name"]
  spec.email = ["your.email@example.com"]

  spec.summary = "A debugging tool for Rails cache operations"
  spec.description = <<~DESC
    Rails Cache Debugger is a powerful tool for debugging and monitoring Rails cache operations.
    It provides detailed logging, performance metrics, and event tracking for cache operations.
    Features include:
    - Detailed logging of cache operations (read, write, delete, etc.)
    - Performance metrics for cache operations
    - Event tracking and filtering
    - Customizable log formats (text and JSON)
    - Sampling rate control for production environments
    - Extensible event handling system
  DESC
  spec.homepage = "https://github.com/yourusername/rails-cache-debugger"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/rails-cache-debugger"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("lib/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "activesupport", ">= 6.0.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-rspec", "~> 2.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "redcarpet", "~> 3.5"
  spec.add_development_dependency "github-markup", "~> 4.0"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "pry-byebug", "~> 3.10"
  spec.add_development_dependency "pry-doc", "~> 1.1"
  spec.add_development_dependency "pry-rescue", "~> 1.5"
  spec.add_development_dependency "pry-stack_explorer", "~> 0.6"
  spec.add_development_dependency "pry-theme", "~> 1.2"
  spec.add_development_dependency "pry-remote", "~> 0.1"
  spec.add_development_dependency "pry-nav", "~> 1.0"
  spec.add_development_dependency "pry-coolline", "~> 0.2"
  spec.add_development_dependency "pry-highlight", "~> 0.1"
  spec.add_development_dependency "pry-macro", "~> 1.0"
  spec.add_development_dependency "pry-rails", "~> 0.3"
end
