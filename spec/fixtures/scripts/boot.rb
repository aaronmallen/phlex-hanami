# frozen_string_literal: true

# Boots the fixture app and reports on it, for specs that need a process of their own.
#
# Set FINALIZE=1 to boot a finalized (production-style) container instead of a prepared one.
# Prints one `key=value` line per assertion, which the calling spec parses.

require "rack/test"

require File.expand_path("../test_app/config/app", __dir__)

ENV["FINALIZE"] == "1" ? TestApp::App.boot : TestApp::App.prepare

session = Rack::Test::Session.new(Rack::MockSession.new(Hanami.app))

puts "hanami_view_bundled=#{Hanami.bundled?('hanami-view')}"
puts "app_view_class=#{TestApp::App['views.posts.index']}"
puts "app_view_is_class=#{TestApp::App['views.posts.index'].is_a?(Class)}"
puts "slice_view_class=#{Admin::Slice['views.posts.index']}"

response = session.get("/posts")
puts "status=#{response.status}"
puts "body=#{response.body}"

second = session.get("/posts")
puts "second_status=#{second.status}"
puts "second_body=#{second.body}"

puts "nested_body=#{session.get('/posts/-/nested').body}"
puts "admin_body=#{session.get('/admin/posts').body}"

# Hanami builds its own context lazily, when the action is instantiated, so only ask for the
# constant once a request has been through.
puts "context_class=#{TestApp::Views::Context}"
ours = TestApp::Views::Context <= Phlex::Hanami::Context
puts "context_is_ours=#{ours == true}"
