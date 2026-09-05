# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Mailer::Renderable do
  describe "layout resolution" do
    it "finds a slice's conventional Views::Mailers::Layout" do
      expect(TestApp::Views::Mailers::Welcome.layout).to be(TestApp::Views::Mailers::Layout)
    end

    it "ignores the slice's web layout" do
      expect(Admin::Views::Mailers::Report.layout).to be_nil
    end

    it "opts out with `layout nil`" do
      expect(TestApp::Views::Mailers::Digest.layout).to be_nil
    end

    it "never wraps a mail layout in a layout" do
      expect(Phlex::Hanami::Mailer::Layout.layout).to be_nil
    end
  end

  describe ".call" do
    it "renders markup for the html format" do
      html = TestApp::Views::Mailers::Digest.call(format: :html, count: 3)

      expect(html).to eq("<p>3 new posts</p>")
    end

    it "defaults to the html format" do
      expect(TestApp::Views::Mailers::Digest.call(count: 3)).to eq("<p>3 new posts</p>")
    end

    it "renders text for the text format" do
      text = TestApp::Views::Mailers::Digest.call(format: :text, count: 3)

      expect(text).to eq("3 new posts, in text")
    end

    it "converts the rendered html when the view has no text of its own" do
      text = TestApp::Views::Mailers::Welcome.call(format: :text, name: "Aaron")

      expect(text).to start_with("Welcome, Aaron")
    end

    it "converts the layout along with the view" do
      text = TestApp::Views::Mailers::Welcome.call(format: :text, name: "Aaron")

      expect(text).to end_with("Sent by TestApp")
    end

    it "drops input the view does not accept" do
      html = TestApp::Views::Mailers::Digest.call(count: 3, unwanted: "dropped")

      expect(html).to eq("<p>3 new posts</p>")
    end

    it "builds the slice's context when given none" do
      html = TestApp::Views::Mailers::Welcome.call(name: "Aaron")

      expect(html).to include(%(href="http://0.0.0.0:2300/posts"))
    end

    it "uses a context it is given" do
      context = Phlex::Hanami::Extensions::Slice.view_context_class(TestApp::App).new

      expect(TestApp::Views::Mailers::Digest.call(context: context, count: 3)).to eq("<p>3 new posts</p>")
    end

    it "resolves a relative translation key against the view's container key" do
      expect(TestApp::Views::Mailers::Translated.call).to eq("<h1>Mail, relatively</h1>")
    end
  end

  describe "#path" do
    it "raises rather than write a link an email client cannot follow" do
      expect { TestApp::Views::Mailers::Relative.call }
        .to raise_error(Phlex::Hanami::RelativePathError, /needs a full URL/)
    end

    it "names `url` in the message" do
      expect { TestApp::Views::Mailers::Relative.call }.to raise_error(/Use `url` instead/)
    end
  end

  describe "request-only context" do
    it "raises for anything a request would have supplied" do
      expect { TestApp::Views::Mailers::Sessioned.call }
        .to raise_error(Hanami::ComponentLoadError, /Request not available/)
    end
  end
end
