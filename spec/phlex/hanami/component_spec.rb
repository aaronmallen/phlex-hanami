# frozen_string_literal: true

require_relative "../../fixtures/shared/badge"

RSpec.describe Phlex::Hanami::Component do
  describe "the slice it belongs to" do
    it "is the slice the component was defined in" do
      expect(TestApp::Components::Card.slice).to be(TestApp::App)
    end

    it "is nil for a component outside every slice namespace" do
      expect(Shared::Badge.slice).to be_nil
    end
  end

  describe "the view contract it does not have" do
    it "has no layout" do
      expect(described_class).not_to respond_to(:layout)
    end

    # Phlex's own `.call` forwards its arguments to `new`, so a component handed to Hanami would
    # take the view context as an initializer keyword rather than as the context. Only a view
    # overrides it.
    it "keeps Phlex's own class-level call rather than the one Hanami renders a view through" do
      expect(described_class.singleton_class.ancestors).not_to include(Phlex::Hanami::Renderable::ClassMethods)
    end
  end

  describe "rendering", type: :view do
    it "reads the view context of whoever renders it" do
      expect(render(TestApp::Components::Card.new(title: "Hello")))
        .to eq(%(<article><h2><a href="/posts">Hello</a></h2></article>))
    end

    it "takes a block" do
      expect(render(TestApp::Components::Card.new(title: "Hello")) { "body" })
        .to eq(%(<article><h2><a href="/posts">Hello</a></h2>body</article>))
    end

    it "reads the context from any depth" do
      expect(render(TestApp::Components::Outer.new)).to include(%(<span id="deep">/posts</span>))
    end

    it "raises when rendered with no context at all" do
      expect { TestApp::Components::Card.new(title: "Hello").call }
        .to raise_error(Phlex::Hanami::MissingContextError, /TestApp::Components::Card/)
    end

    context "when the component is outside every slice namespace" do
      it "still reads the context" do
        expect(render(Shared::Badge.new)).to eq(%(<span id="badge">/posts</span>))
      end

      it "raises a helpful error for a relative translation key" do
        component = Class.new(Shared::Badge) do
          def view_template = span { t(".title") }
        end

        expect { render(component.new) }.to raise_error(I18n::ArgumentError, /Cannot resolve/)
      end
    end
  end

  describe "sharing a component across slices", type: :request do
    it "renders an app component inside a slice's view" do
      get "/admin/posts/shared"

      expect(last_response.body).to eq(%(<article><h2><a href="/posts">Shared</a></h2></article>))
    end
  end

  describe "kits" do
    it "registers the kit module as the module rather than instantiating it" do
      expect(TestApp::App["components"]).to be(TestApp::Components)
    end

    it "still registers a component as its class" do
      expect(TestApp::App["components.card"]).to be(TestApp::Components::Card)
    end

    it "defines a method for each component in the namespace" do
      expect(TestApp::Components).to respond_to(:Card)
    end

    it "lets a view that includes the kit call a component as a method", type: :request do
      get "/posts/-/kitted"

      expect(last_response.body)
        .to include(%(<article><h2><a href="/posts">Kitted</a></h2><p>body</p></article>))
    end

    it "lets a component call a sibling as a method" do
      expect(TestApp::Components::Card.ancestors).to include(TestApp::Components)
    end
  end
end
