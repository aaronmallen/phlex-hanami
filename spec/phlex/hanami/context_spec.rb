# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Context do
  subject(:context) { TestApp::Views::Context.new(**attributes) }

  let(:attributes) { {} }

  before { skip "hanami-view is bundled, so Hanami provides the context" if Hanami.bundled?("hanami-view") }

  describe "#request" do
    it "raises a clear error when there is no request" do
      expect { context.request }
        .to raise_error(Hanami::ComponentLoadError, /Only views rendered from Hanami::Action/)
    end

    it "returns the request when there is one" do
      request = instance_double(Hanami::Action::Request)

      expect(described_class.new(request: request).request).to be(request)
    end
  end

  describe "#request?" do
    it "is false without a request" do
      expect(context.request?).to be(false)
    end

    it "is true with a request" do
      request = instance_double(Hanami::Action::Request)

      expect(described_class.new(request: request).request?).to be(true)
    end
  end

  describe "#routes" do
    it "is injected from the slice" do
      expect(context.routes).to be_a(Hanami::Slice::RoutesHelper)
    end

    it "raises when routes are unavailable" do
      expect { described_class.new.routes }
        .to raise_error(Hanami::ComponentLoadError, /hanami-router gem is required/)
    end
  end

  describe "#assets" do
    it "raises when hanami-assets is not bundled" do
      expect { context.assets }.to raise_error(Hanami::ComponentLoadError, /Assets not available/)
    end
  end

  describe "#i18n" do
    it "is injected from the slice" do
      expect(context.i18n).not_to be_nil
    end

    it "raises when nothing was injected" do
      expect { described_class.new.i18n }
        .to raise_error(Hanami::ComponentLoadError, /i18n gem is required/)
    end
  end

  describe "#inflector" do
    it "is injected from the slice" do
      expect(context.inflector).to be(TestApp::App.inflector)
    end
  end

  describe "#content_for" do
    it "stores and reads back a value" do
      context.content_for(:title, "Hello")

      expect(context.content_for(:title)).to eq("Hello")
    end

    it "stores the result of a block" do
      context.content_for(:title) { "From a block" }

      expect(context.content_for(:title)).to eq("From a block")
    end

    it "returns nil for an unset key" do
      expect(context.content_for(:missing)).to be_nil
    end

    it "does not leak stored content into a copy's source" do
      copy = context.dup
      copy.content_for(:title, "Only mine")

      expect(context.content_for(:title)).to be_nil
    end
  end

  describe "#session and #flash" do
    it "raise without a request" do
      expect { context.session }.to raise_error(Hanami::ComponentLoadError)
      expect { context.flash }.to raise_error(Hanami::ComponentLoadError)
    end
  end
end
