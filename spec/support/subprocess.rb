# frozen_string_literal: true

require "open3"
require "shellwords"

# Runs Ruby against the fixture app in a fresh process.
#
# Some behaviour can only be observed once per process: a finalized container, or a Gemfile that
# does or does not include hanami-view. Those specs shell out rather than trying to unpick global
# state.
module Subprocess
  SCRIPTS = File.expand_path("../fixtures/scripts", __dir__)

  # @param script [String] a file name under `spec/fixtures/scripts`
  # @param gemfile [String, nil] a Gemfile to run under, defaulting to the project's own
  # @param env [Hash] extra environment variables
  #
  # @return [Array(String, String, Process::Status)] stdout, stderr, status
  def self.run(script, gemfile: nil, **env)
    environment = { "HANAMI_ENV" => "test" }.merge(env.transform_keys(&:to_s))
    environment["BUNDLE_GEMFILE"] = gemfile if gemfile

    Open3.capture3(environment, "bundle", "exec", "ruby", File.join(SCRIPTS, script))
  end
end
