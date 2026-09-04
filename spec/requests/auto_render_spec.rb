# frozen_string_literal: true

RSpec.describe "auto-rendering Phlex views", type: :request do
  it "renders the paired view for an action that never calls response.render" do
    get "/posts"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("<h1>Posts</h1>")
  end

  it "renders the same view again on a second request" do
    2.times { get "/posts" }

    expect(last_response.body).to include("<h1>Posts</h1>")
  end

  it "renders a view from a slice" do
    get "/admin/posts"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("<h2>Admin posts</h2>")
  end

  it "passes request params to the view" do
    get "/posts/42"

    expect(last_response.body).to include("<h1>Post 42</h1>")
  end

  it "falls back to the 'new' view for a 'create' action" do
    post "/posts"

    expect(last_response.body).to include("<h1>New post</h1>")
    expect(last_response.body).to include("<li>Title is required</li>")
  end

  it "does not render its paired view when the action redirects" do
    get "/posts/-/redirect"

    expect(last_response.status).to eq(302)
    expect(last_response.body).not_to include("SHOULD NOT RENDER")
  end

  it "does not render when the action already set a body" do
    get "/posts/-/prerendered"

    expect(last_response.body).to eq("set by the action")
  end

  it "leaves an action with no paired view alone" do
    get "/posts/-/viewless"

    expect(last_response.body).to eq("no view for this action")
  end

  it "gives exposures precedence over params of the same name" do
    get "/posts/-/anything?exposed=from-the-client"

    expect(last_response.body).to include("exposed=exposure")
  end

  it "passes request params to a view whose initializer takes keyrest" do
    get "/posts/-/anything?extra=1"

    expect(last_response.body).to include("extra=1")
  end

  it "hands the same context to a component nested three levels deep" do
    get "/posts/-/nested"

    expect(last_response.body).to include(%(<span id="deep">/posts</span>))
  end

  it "renders route helpers from the view's context" do
    get "/posts"

    expect(last_response.body).to include(%(<a href="/posts">All posts</a>))
  end

  it "uses the default view name inferrer" do
    expect(TestApp::App.config.actions.view_name_inferrer)
      .to be(Hanami::Slice::ViewNameInferrer)
  end

  it "surfaces an error raised inside a view" do
    view = Class.new(TestApp::View) do
      def view_template = raise("boom")
    end

    expect { view.call }.to raise_error(RuntimeError, "boom")
  end
end
