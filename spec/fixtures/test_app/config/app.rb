# frozen_string_literal: true

require "hanami"
require "phlex-hanami"

module TestApp
  class App < Hanami::App
    config.root = File.expand_path("..", __dir__)
    config.logger.stream = File::NULL
    config.actions.sessions = :cookie, { secret: "a" * 64 }
  end
end
