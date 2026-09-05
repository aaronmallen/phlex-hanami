# frozen_string_literal: true

# `Hanami.bundled?` is decided by the Gemfile the process was started with, and hanami-mailer
# behaves differently depending on whether hanami-view is there: with it, mailers grow a view
# integration of their own that ours has to sit in front of. So this runs in a subprocess for each.
RSpec.describe "delivering mail from Phlex views" do
  subject(:report) do
    stdout, stderr, status = Subprocess.run("mail.rb", gemfile: gemfile)
    raise "subprocess failed:\n#{stderr}" unless status.success?

    stdout.lines.to_h { |line| line.chomp.split("=", 2) }
  end

  shared_examples "a working mail integration" do
    it "pairs the mailer with its Phlex view" do
      expect(report["welcome_view"]).to eq("TestApp::Views::Mailers::Welcome")
    end

    it "renders the html part inside the mail layout" do
      expect(report["welcome_html"]).to include("<h1>Welcome, Aaron</h1>")
      expect(report["welcome_html"]).to include("<p>Sent by TestApp</p>")
    end

    it "renders a text part from the same view" do
      expect(report["welcome_text"]).to include("Welcome, Aaron")
      expect(report["welcome_text"]).to include("- All posts <http://0.0.0.0:2300/posts>")
    end

    it "lets a view write its own text part" do
      expect(report["digest_html"]).to eq(%("<p>3 new posts</p>"))
      expect(report["digest_text"]).to eq(%("3 new posts, in text"))
    end

    it "renders a slice's mail from that slice's view" do
      expect(report["report_html"]).to eq(%("<h2>Admin report</h2>"))
    end

    it "renders nothing for a mailer with no Phlex view" do
      expect(report["unpaired_html"]).to eq("nil")
    end
  end

  let(:gemfile) { nil }

  describe "without hanami-view" do
    it_behaves_like "a working mail integration"

    it "runs against our own view context" do
      expect(report["hanami_view_bundled"]).to eq("false")
    end
  end

  describe "with hanami-view bundled" do
    let(:gemfile) { File.expand_path("../fixtures/gemfiles/hanami_view.gemfile", __dir__) }

    it_behaves_like "a working mail integration"

    it "runs against Hanami's own view context" do
      expect(report["hanami_view_bundled"]).to eq("true")
    end
  end
end
