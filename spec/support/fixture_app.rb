# frozen_string_literal: true

require "rack/test"

# Boots the fixture Hanami app once for the suite.
#
# `Hanami.app` is process-global — an app registers itself on `inherited` and cannot be swapped out
# — so the suite boots one app and shares it. Anything that needs a different global (a finalized
# container, a different Gemfile) runs in a subprocess; see `Subprocess`.
module FixtureApp
  ROOT = File.expand_path("../fixtures/test_app", __dir__)

  class << self
    def boot!
      return if defined?(@booted)

      ENV["HANAMI_ENV"] = "test"
      require File.join(ROOT, "config", "app")
      TestApp::App.prepare
      @booted = true
    end
  end

  # Request helpers for specs tagged `type: :request`.
  module RequestHelpers
    include Rack::Test::Methods

    def app
      Hanami.app
    end
  end
end

FixtureApp.boot!

RSpec.configure do |config|
  config.include FixtureApp::RequestHelpers, type: :request
end
