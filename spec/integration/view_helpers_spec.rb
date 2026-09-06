# frozen_string_literal: true

# The helpers build whichever context class the app would build, and hanami-view decides which that
# is. Which gem is bundled can only be settled once per process, so both runs shell out.
RSpec.describe "the RSpec helpers in an app's own suite" do
  subject(:output) do
    stdout, stderr, status = Subprocess.run("view_helpers.rb", gemfile: gemfile)
    raise "subprocess failed:\n#{stderr}" unless status.success?

    stdout.lines.to_h { |line| line.chomp.split("=", 2) }
  end

  shared_examples "renders a view" do
    it "renders with the slice's routes" do
      expect(output.fetch("body")).to eq(%(<h1>Posts</h1><a href="/posts">All posts</a>))
    end

    it "renders a view that reads the session, the flash and the CSRF token" do
      expect(output.fetch("sessioned"))
        .to eq(%(<p id="user">Ada</p><p id="notice">Saved</p><p id="token">a-token</p><p id="path">/posts</p>))
    end
  end

  context "without hanami-view" do
    let(:gemfile) { nil }

    it "builds our own context" do
      expect(output.fetch("context_class")).to eq("Phlex::Hanami::Context")
    end

    it_behaves_like "renders a view"
  end

  context "with hanami-view" do
    let(:gemfile) { File.expand_path("../fixtures/gemfiles/hanami_view.gemfile", __dir__) }

    it "builds Hanami's own context" do
      expect(output.fetch("context_class")).to eq("Hanami::View::Context")
    end

    it_behaves_like "renders a view"
  end
end
