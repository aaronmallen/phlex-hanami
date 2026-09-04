# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Layout do
  describe "resolution" do
    it "finds a slice's conventional Views::Layout" do
      expect(Admin::Views::Posts::Index.layout).to be(Admin::Views::Layout)
    end

    it "is nil for a slice with no conventional layout" do
      expect(TestApp::Views::Posts::Index.layout).to be_nil
    end

    it "uses an explicitly set layout" do
      expect(TestApp::Views::Posts::Boxed.layout).to be(TestApp::Views::BoxLayout)
    end

    it "opts out with `layout nil`, overriding the slice convention" do
      expect(Admin::Views::Posts::Bare.layout).to be_nil
    end

    it "inherits an explicit layout from a superclass" do
      subclass = Class.new(TestApp::Views::Posts::Boxed)

      expect(subclass.layout).to be(TestApp::Views::BoxLayout)
    end

    it "lets a subclass override an inherited layout" do
      subclass = Class.new(TestApp::Views::Posts::Boxed) { layout nil }

      expect(subclass.layout).to be_nil
    end

    it "never wraps a layout in a layout" do
      expect(described_class.layout).to be_nil
    end
  end

  describe "rendering", type: :request do
    it "wraps a slice view in the slice's conventional layout" do
      get "/admin/posts"

      expect(last_response.body).to start_with("<html>")
      expect(last_response.body).to include("<h2>Admin posts</h2>")
    end

    it "renders the body before the layout, so content_for is visible in the head" do
      get "/admin/posts"

      expect(last_response.body).to include("<title>Set by the view</title>")
    end

    it "does not wrap a view that opted out" do
      get "/admin/posts/bare"

      expect(last_response.body).to eq("<h2>No layout here</h2>")
    end

    it "wraps a view in its explicitly configured layout" do
      get "/posts/-/boxed"

      expect(last_response.body).to eq(%(<div class="box"><h1>Boxed</h1></div>))
    end

    it "leaves a view with no layout unwrapped" do
      get "/posts"

      expect(last_response.body).not_to include("<html>")
    end
  end
end
