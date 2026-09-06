# frozen_string_literal: true

RSpec.describe "response formats", type: :request do
  describe "content type" do
    it "follows the Accept header" do
      get "/posts", {}, { "HTTP_ACCEPT" => "text/html" }

      expect(last_response.headers["content-type"]).to eq("text/html; charset=utf-8")
      expect(last_response.body).to include("<h1>Posts</h1>")
    end

    it "matches an action that sets its own body, with an Accept header" do
      get "/posts", {}, { "HTTP_ACCEPT" => "text/html" }
      rendered = last_response.headers["content-type"]

      get "/posts/-/viewless", {}, { "HTTP_ACCEPT" => "text/html" }

      expect(last_response.headers["content-type"]).to eq(rendered)
    end

    it "matches an action that sets its own body, with no Accept header" do
      get "/posts"
      rendered = last_response.headers["content-type"]

      get "/posts/-/viewless"

      expect(last_response.headers["content-type"]).to eq(rendered)
    end
  end

  describe "an action configured for JSON" do
    # Hanami's `auto_render?` is `view && res.body.empty?`; it never looks at the format. A view
    # that happens to match a JSON action by name is rendered into the JSON response. This is
    # Hanami's behaviour with hanami-view too, so the spec pins it rather than working around it.
    it "renders a name-matched view into the JSON response" do
      get "/posts/-/feed"

      expect(last_response.headers["content-type"]).to eq("application/json; charset=utf-8")
      expect(last_response.body).to eq("<h1>Posts</h1>")
    end

    it "refuses a request that asks for HTML, before anything renders" do
      get "/posts/-/feed", {}, { "HTTP_ACCEPT" => "text/html" }

      expect(last_response.status).to eq(406)
      expect(last_response.body).not_to include("<h1>")
    end
  end

  describe "a HEAD request" do
    it "returns no body" do
      head "/posts"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to be_empty
    end

    it "returns the same content type as the GET" do
      get "/posts", {}, { "HTTP_ACCEPT" => "text/html" }
      rendered = last_response.headers["content-type"]

      head "/posts", {}, { "HTTP_ACCEPT" => "text/html" }

      expect(last_response.headers["content-type"]).to eq(rendered)
    end

    it "empties the body the same way for an action that sets its own" do
      head "/posts/-/viewless"

      expect(last_response.body).to be_empty
    end
  end

  describe "opting an action out" do
    it "renders nothing when the action overrides auto_render?" do
      get "/posts/-/opted-out"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to be_empty
    end

    it "still renders the paired view when asked for directly" do
      expect(TestApp::Views::Posts::OptedOut.call).to include("SHOULD NOT RENDER")
    end

    it "still renders for the format the action kept" do
      get "/posts/-/conditional", {}, { "HTTP_ACCEPT" => "text/html" }

      expect(last_response.body).to eq("<h1>Posts</h1>")
    end

    it "renders nothing for the format the action dropped" do
      get "/posts/-/conditional", {}, { "HTTP_ACCEPT" => "application/json" }

      expect(last_response.headers["content-type"]).to eq("application/json; charset=utf-8")
      expect(last_response.body).to be_empty
    end
  end
end
