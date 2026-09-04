# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Extensions::Slice do
  describe "component registration" do
    it "registers an app view as the class, not an instance" do
      expect(TestApp::App["views.posts.index"]).to be(TestApp::Views::Posts::Index)
    end

    it "registers a slice view as the class" do
      expect(Admin::Slice["views.posts.index"]).to be(Admin::Views::Posts::Index)
    end

    it "registers a Phlex class that does not include Renderable as the class" do
      expect(TestApp::App["views.posts.plain"]).to be(TestApp::Views::Posts::Plain)
    end

    it "registers a Phlex component as the class" do
      expect(TestApp::App["components.inner"]).to be(TestApp::Components::Inner)
    end

    it "still registers non-Phlex components as instances" do
      expect(TestApp::App["actions.posts.index"]).to be_a(TestApp::Actions::Posts::Index)
    end

    it "answers key? without instantiating the view" do
      expect(TestApp::App.key?("views.posts.index")).to be(true)
    end
  end

  describe "view context" do
    it "defines a Views::Context for the app when hanami-view is not bundled" do
      skip "hanami-view is bundled" if Hanami.bundled?("hanami-view")

      expect(TestApp::Views::Context).to be < Phlex::Hanami::Context
    end

    it "defines a Views::Context for each slice" do
      skip "hanami-view is bundled" if Hanami.bundled?("hanami-view")

      expect(Admin::Views::Context).to be < Phlex::Hanami::Context
    end

    it "configures each slice's context for that slice" do
      skip "hanami-view is bundled" if Hanami.bundled?("hanami-view")

      expect(configured_slice_for(Admin::Views::Context)).to be(Admin::Slice)
    end

    it "configures the app's context for the app" do
      skip "hanami-view is bundled" if Hanami.bundled?("hanami-view")

      expect(configured_slice_for(TestApp::Views::Context)).to be(TestApp::App)
    end

    it "injects the slice's routes into its context" do
      skip "hanami-view is bundled" if Hanami.bundled?("hanami-view")

      expect(Admin::Views::Context.new.routes).to be_a(Hanami::Slice::RoutesHelper)
    end

    def configured_slice_for(context_class)
      context_class.singleton_class.ancestors
        .find { |mod| mod.is_a?(Phlex::Hanami::SliceConfiguredContext) }
        &.slice
    end
  end
end
