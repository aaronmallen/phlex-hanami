# frozen_string_literal: true

# Delivers the fixture app's mail and reports on it, for specs that need a process of their own.
#
# Prints one `key=value` line per assertion, which the calling spec parses. Bodies are inspected,
# because a text part has newlines in it and the report is line based.

require File.expand_path("../test_app/config/app", __dir__)
TestApp::App.prepare

welcome = TestApp::App["mailers.welcome"].deliver(name: "Aaron").message
digest = TestApp::App["mailers.digest"].deliver(count: 3).message
report = Admin::Slice["mailers.report"].deliver.message

puts "hanami_view_bundled=#{Hanami.bundled?('hanami-view')}"
puts "welcome_view=#{TestApp::Mailers::Welcome.phlex_view}"
puts "welcome_html=#{welcome.html_body.inspect}"
puts "welcome_text=#{welcome.text_body.inspect}"
puts "digest_html=#{digest.html_body.inspect}"
puts "digest_text=#{digest.text_body.inspect}"
puts "report_html=#{report.html_body.inspect}"
puts "unpaired_html=#{TestApp::App['mailers.unpaired'].deliver.message.html_body.inspect}"
