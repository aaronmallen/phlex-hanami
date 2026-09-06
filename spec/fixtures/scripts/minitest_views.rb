# frozen_string_literal: true

# Runs the view helpers under Minitest, the way an app generated with `hanami new --test=minitest`
# would. Runs in a subprocess because `minitest/autorun` installs an `at_exit` runner.

require File.expand_path("../test_app/config/app", __dir__)
TestApp::App.prepare

require "minitest/autorun"
require "phlex/hanami/testing"

# The line an app writes in `test/support`, against `Hanami::Minitest::Test` in a real app.
class ViewTest < Minitest::Test
  include Phlex::Hanami::Testing::ViewHelpers
end

class PostsIndexTest < ViewTest
  def test_builds_a_context_for_a_slice
    assert_instance_of Admin::Views::Context, view_context(slice: Admin::Slice)
  end

  def test_renders_a_view_that_reads_the_request
    request = view_request("/posts", csrf_token: "a-token", flash: { notice: "Saved" }, session: { user: "Ada" })
    html = render(TestApp::Views::SessionPanel.new, request: request)

    assert_equal %(<p id="user">Ada</p><p id="notice">Saved</p><p id="token">a-token</p><p id="path">/posts</p>), html
  end

  def test_renders_the_view_with_the_slice_routes
    html = render(TestApp::Views::Posts::Index.new(title: "Posts"))

    assert_equal %(<h1>Posts</h1><a href="/posts">All posts</a>), html
  end
end
