# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Extensions::Mailer do
  describe ".phlex_view" do
    it "pairs a mailer with the view whose container key matches" do
      expect(TestApp::Mailers::Welcome.phlex_view).to be(TestApp::Views::Mailers::Welcome)
    end

    it "pairs within the mailer's own slice" do
      expect(Admin::Mailers::Report.phlex_view).to be(Admin::Views::Mailers::Report)
    end

    it "is nil for a mailer with no matching view" do
      expect(TestApp::Mailers::Unpaired.phlex_view).to be_nil
    end

    it "is nil for a mailer outside any slice" do
      expect(Hanami::Mailer.phlex_view).to be_nil
    end

    it "refuses a view that renders markup for both parts of the message" do
      expect { TestApp::Mailers::Mismatched.phlex_view }
        .to raise_error(Phlex::Hanami::MailerViewError, /is not a mail view/)
    end

    it "resolves the view as a class, not an instance" do
      expect(TestApp::Mailers::Welcome.phlex_view).to be_a(Class)
    end
  end

  describe "#view" do
    it "is the paired Phlex view" do
      expect(TestApp::App["mailers.welcome"].view).to be(TestApp::Views::Mailers::Welcome)
    end

    it "prefers a view passed to the constructor" do
      given = Class.new(Phlex::Hanami::Mailer::View)

      expect(TestApp::Mailers::Welcome.new(view: given).view).to be(given)
    end

    it "falls through when the mailer has no Phlex view" do
      expect(TestApp::App["mailers.unpaired"].view).to be_nil
    end
  end

  describe "delivery" do
    subject(:message) { TestApp::App["mailers.welcome"].deliver(name: "Aaron").message }

    it "renders the html part from the Phlex view" do
      expect(message.html_body).to include("<h1>Welcome, Aaron</h1>")
    end

    it "renders a text part alongside it" do
      expect(message.text_body).to include("Welcome, Aaron")
    end

    it "does not send markup as the text part" do
      expect(message.text_body).not_to include("<h1>")
    end

    it "renders only the requested part" do
      html_only = TestApp::App["mailers.welcome"].deliver(name: "Aaron", format: :html).message

      expect(html_only.html_body).not_to be_nil
      expect(html_only.text_body).to be_nil
    end

    it "renders nothing for a mailer with no view" do
      message = TestApp::App["mailers.unpaired"].deliver.message

      expect(message.html_body).to be_nil
      expect(message.text_body).to be_nil
    end

    it "lets a view write its own text part" do
      message = TestApp::App["mailers.digest"].deliver(count: 3).message

      expect(message.html_body).to eq("<p>3 new posts</p>")
      expect(message.text_body).to eq("3 new posts, in text")
    end

    it "delivers a slice's mail from that slice's view" do
      message = Admin::Slice["mailers.report"].deliver.message

      expect(message.html_body).to eq("<h2>Admin report</h2>")
    end
  end
end
