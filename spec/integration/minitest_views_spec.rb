# frozen_string_literal: true

# `minitest/autorun` installs an `at_exit` runner, so this cannot share a process with the suite.
RSpec.describe "the view helpers under Minitest" do
  it "passes every test" do
    stdout, stderr, status = Subprocess.run("minitest_views.rb")

    expect(stdout).to include("3 runs, 3 assertions, 0 failures, 0 errors, 0 skips"), stderr
    expect(status).to be_success
  end
end
