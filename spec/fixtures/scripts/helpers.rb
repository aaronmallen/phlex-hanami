# frozen_string_literal: true

# Renders the helper fixture view. Needs a Gemfile with hanami-view, and `HANAMI_ENV=development`
# for a CSRF token — Hanami disables its CSRF callbacks in the test env.

require "rack/test"

require File.expand_path("../test_app/config/app", __dir__)
TestApp::App.prepare

session = Rack::Test::Session.new(Rack::MockSession.new(Hanami.app))

puts "hanami_view_bundled=#{Hanami.bundled?('hanami-view')}"
puts "body=#{session.get('/posts/-/form').body}"
