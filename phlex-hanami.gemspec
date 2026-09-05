# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "phlex-hanami"
  spec.version = "0.2.0-alpha.2"
  spec.authors = ["Aaron Allen"]
  spec.email = ["hello@aaronmallen.me"]

  spec.summary = "A Phlex adapter for Hanami"
  spec.description = <<~DESC
    An object oriented view layer for Hanami. Write views, layouts, and components as Phlex classes instead of
    templates.
  DESC
  spec.homepage = "https://github.com/aaronmallen/phlex-hanami"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.metadata = {
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true",
    "source_code_uri" => spec.homepage,
  }

  spec.files = Dir["lib/**/*", "sig/**/*", "LICENSE", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "hanami", "~> 3"
  spec.add_dependency "phlex", "~> 2"
  spec.add_dependency "zeitwerk", "~> 2"
end
