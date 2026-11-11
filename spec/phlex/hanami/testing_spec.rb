# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Testing::ViewHelpers, type: :view do
  describe "#render" do
    it "returns the markup" do
      expect(render(TestApp::Views::Posts::Index.new(title: "Posts"))).to include("<h1>Posts</h1>")
    end

    it "builds a context from the view's own slice" do
      expect(render(TestApp::Views::Posts::Index.new(title: "Posts")))
        .to include(%(<a href="/posts">All posts</a>))
    end

    it "builds a context from the slice the view belongs to, not the app" do
      expect(render(Admin::Views::Posts::Index.new(title: "Admin posts")))
        .to eq("<h2>Admin posts</h2>")
    end

    it "applies no layout, even for a view that has one" do
      expect(Admin::Views::Posts::Index.layout).to be(Admin::Views::Layout)
      expect(render(Admin::Views::Posts::Index.new(title: "Admin posts"))).not_to include("<html")
    end

    it "passes a block through to the view" do
      component = Class.new(TestApp::View) do
        def view_template = div { yield }
      end

      expect(render(component.new) { "from the block" }).to eq("<div>from the block</div>")
    end

    it "renders a plain Phlex class that knows nothing about Hanami" do
      component = Class.new(Phlex::HTML) do
        def view_template = span { "plain" }
      end

      expect(render(component.new)).to eq("<span>plain</span>")
    end

    it "takes a context built by hand" do
      context = Phlex::Hanami::Context.new
      context.content_for(:title, "set outside")
      view = Class.new(TestApp::View) do
        def view_template = h1 { content_for(:title) }
      end

      expect(render(view.new, context: context)).to eq("<h1>set outside</h1>")
    end
  end

  describe "#view_context" do
    it "builds the context class the slice uses" do
      expect(view_context(slice: Admin::Slice)).to be_an_instance_of(Admin::Views::Context)
    end

    it "defaults to the app" do
      expect(view_context).to be_an_instance_of(TestApp::Views::Context)
    end

    it "injects the slice's routes" do
      expect(view_context.routes.path(:posts)).to eq("/posts")
    end

    # Hanami turns off container memoization in the test env so components can be stubbed, so a
    # context that held onto its dependencies would hand out objects from an earlier example.
    it "resolves its dependencies fresh each time" do
      expect(view_context.routes).not_to be(view_context.routes)
    end

    it "carries the request it is given" do
      request = view_request("/posts")

      expect(view_context(request: request).request).to be(request)
    end

    it "has no request by default" do
      expect(view_context.request?).to be(false)
    end
  end

  describe "#view_request" do
    it "renders a view that reads the session, the flash and the CSRF token" do
      request = view_request(
        "/posts",
        csrf_token: "a-token",
        flash: { notice: "Saved" },
        session: { user: "Ada" },
      )

      html = render(TestApp::Views::SessionPanel.new, request: request)

      expect(html).to include(%(<p id="user">Ada</p>))
      expect(html).to include(%(<p id="notice">Saved</p>))
      expect(html).to include(%(<p id="token">a-token</p>))
    end

    it "enables sessions, so an empty one reads back empty rather than raising" do
      expect(view_request.session[:anything]).to be_nil
    end

    it "exposes the path and query as params" do
      request = view_request("/posts?page=2")

      expect(request.params[:page]).to eq("2")
      expect(request.path).to eq("/posts")
    end
  end
end
