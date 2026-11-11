# frozen_string_literal: true

# Renders through the RSpec helpers. Run under the hanami-view Gemfile it proves the helpers build
# Hanami's own context class, not ours.

require "rspec/core"

require File.expand_path("../test_app/config/app", __dir__)
TestApp::App.prepare

require "phlex/hanami/rspec"

helpers = Object.new.extend(Phlex::Hanami::Testing::ViewHelpers)

puts "hanami_view_bundled=#{Hanami.bundled?('hanami-view')}"
puts "context_class=#{helpers.view_context.class.superclass}"
puts "body=#{helpers.render(TestApp::Views::Posts::Index.new(title: 'Posts'))}"
puts "sessioned=#{helpers.render(
  TestApp::Views::SessionPanel.new,
  request: helpers.view_request('/posts', csrf_token: 'a-token', flash: { notice: 'Saved' }, session: { user: 'Ada' }),
)}"
