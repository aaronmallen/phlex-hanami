# frozen_string_literal: true

# These run the fixture app in a fresh process, because each combination needs a different
# process-global: a finalized container cannot be un-finalized, and `Hanami.bundled?` is decided by
# the Gemfile the process was started with.
RSpec.describe "booting the fixture app" do
  subject(:report) do
    stdout, stderr, status = Subprocess.run("boot.rb", gemfile: gemfile, **env)
    raise "subprocess failed:\n#{stderr}" unless status.success?

    stdout.lines.to_h { |line| line.chomp.split("=", 2) }
  end

  shared_examples "a working integration" do
    it "resolves the app view as a class" do
      expect(report["app_view_is_class"]).to eq("true")
      expect(report["app_view_class"]).to eq("TestApp::Views::Posts::Index")
    end

    it "resolves a slice view as a class" do
      expect(report["slice_view_class"]).to eq("Admin::Views::Posts::Index")
    end

    it "auto-renders the view" do
      expect(report["status"]).to eq("200")
      expect(report["body"]).to include("<h1>Posts</h1>")
    end

    it "renders again on a second request" do
      expect(report["second_body"]).to include("<h1>Posts</h1>")
    end

    it "renders a slice view" do
      expect(report["admin_body"]).to include("<h2>Admin posts</h2>")
    end

    it "reaches a component nested three levels deep with the context" do
      expect(report["nested_body"]).to eq(%(<div><div><span id="deep">/posts</span></div></div>))
    end
  end

  let(:env) { {} }
  let(:gemfile) { nil }

  describe "a prepared (lazy) container" do
    it_behaves_like "a working integration"

    it "defines our own view context" do
      expect(report["hanami_view_bundled"]).to eq("false")
      expect(report["context_is_ours"]).to eq("true")
    end
  end

  describe "a finalized container" do
    let(:env) { { FINALIZE: "1" } }

    it_behaves_like "a working integration"
  end

  describe "with hanami-view bundled" do
    let(:gemfile) { File.expand_path("../fixtures/gemfiles/hanami_view.gemfile", __dir__) }

    it_behaves_like "a working integration"

    it "leaves Hanami's own view context in place" do
      expect(report["hanami_view_bundled"]).to eq("true")
      expect(report["context_is_ours"]).to eq("false")
    end
  end
end
