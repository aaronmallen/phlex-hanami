# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Renderable do
  describe ".call" do
    it "returns a String, satisfying Response#render's to_str" do
      expect(TestApp::Views::Posts::Show.call(context: nil, id: 1)).to be_a(String)
    end

    it "drops input the initializer does not declare" do
      expect { TestApp::Views::Posts::Show.call(id: 1, unexpected: "dropped") }
        .not_to raise_error
    end

    it "raises the initializer's own error when a declared keyword is missing" do
      expect { TestApp::Views::Posts::Show.call }
        .to raise_error(ArgumentError, /missing keyword: :id/)
    end

    it "passes everything to a view whose initializer takes keyrest" do
      html = TestApp::Views::Posts::Anything.call(a: 1, b: 2)

      expect(html).to include("a=1 b=2")
    end

    it "does not pass the Hanami context as an initializer keyword" do
      html = TestApp::Views::Posts::Anything.call(context: Phlex::Hanami::Context.new)

      expect(html).not_to include("context=")
    end

    it "renders the same class more than once" do
      2.times { expect(TestApp::Views::Posts::Show.call(id: 1)).to include("Post 1") }
    end
  end

  describe "per-slice configuration" do
    it "configures an app view for the app" do
      expect(TestApp::Views::Posts::Index.slice).to be(TestApp::App)
    end

    it "configures a slice view for its slice" do
      expect(Admin::Views::Posts::Index.slice).to be(Admin::Slice)
    end

    it "reports no slice for a view defined outside a slice namespace" do
      expect(Class.new(Phlex::Hanami::View).slice).to be_nil
    end

    it "exposes the slice on instances too" do
      view = TestApp::Views::Posts::Index.new(title: "t")

      expect(view.slice).to be(TestApp::App)
    end
  end

  describe "#hanami_context" do
    it "raises a helpful error when the view was rendered without one" do
      view = Class.new(Phlex::Hanami::View) do
        def view_template = plain(hanami_context.to_s)
      end

      expect { view.call }.to raise_error(Phlex::Hanami::MissingContextError, /without a Hanami view context/)
    end

    it "reports false from #hanami_context? when there is none" do
      view = Class.new(Phlex::Hanami::View) do
        def view_template = plain(hanami_context?.to_s)
      end

      expect(view.call).to include("false")
    end

    it "reports false from #request? when there is no context" do
      view = Class.new(Phlex::Hanami::View) do
        def view_template = plain(request?.to_s)
      end

      expect(view.call).to include("false")
    end
  end

  describe "#asset_url" do
    it "raises a clear error when hanami-assets is not bundled" do
      view = Class.new(TestApp::View) do
        def view_template = plain(asset_url("app.js"))
      end

      expect { view.call(context: TestApp::Views::Context.new) }
        .to raise_error(Hanami::ComponentLoadError, /Assets not available/)
    end
  end

  describe "including the module directly" do
    it "is equivalent to subclassing Phlex::Hanami::View" do
      view = Class.new(Phlex::HTML) do
        include Phlex::Hanami::Renderable

        def initialize(title:)
          @title = title
        end

        def view_template = h1 { @title }
      end

      expect(view.call(title: "Included", dropped: true)).to eq("<h1>Included</h1>")
    end
  end
end
