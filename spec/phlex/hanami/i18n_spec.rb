# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Contextual::I18nOverrides do
  describe "rendering", type: :request do
    before { get "/posts/-/translated" }

    it "translates an absolute key" do
      expect(last_response.body).to include("<h1>Hello from i18n</h1>")
    end

    it "resolves a relative key from the view's own container key" do
      expect(last_response.body).to include(%(<p id="relative">Posts, relatively</p>))
    end

    # Without hanami-view, `I18nHelper#_i18n_mark_html_safe` has no `html_safe` to call, so the
    # markup comes back as an ordinary String and Phlex escapes it — correctly, since Phlex has no
    # way to know it is trusted. With hanami-view bundled it is a SafeString and renders as markup.
    it "escapes Hanami's missing-translation markup when hanami-view is not bundled" do
      skip "hanami-view is bundled" if Hanami.bundled?("hanami-view")

      expect(last_response.body).to include("&lt;span class=&quot;translation_missing&quot;")
    end
  end

  describe "#i18n_key_base" do
    it "drops the slice and Views namespaces from an app view's name" do
      view = TestApp::Views::Posts::Translated.new

      expect(view.send(:i18n_key_base)).to eq("posts.translated")
    end

    it "drops the slice's own namespace for a slice view" do
      view = Admin::Views::Posts::Index.new(title: "t")

      expect(view.send(:i18n_key_base)).to eq("posts.index")
    end

    it "is nil for an anonymous view" do
      view = Class.new(TestApp::View).new

      expect(view.send(:i18n_key_base)).to be_nil
    end
  end

  describe "#_resolve_i18n_key" do
    it "raises a clear error for a relative key it cannot resolve" do
      view = Class.new(TestApp::View) do
        def view_template = plain(t(".title"))
      end

      expect { view.call }
        .to raise_error(I18n::ArgumentError, /Cannot resolve the relative translation key/)
    end
  end
end
