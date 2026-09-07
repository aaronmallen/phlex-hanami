# frozen_string_literal: true

module TestApp
  class Routes < Hanami::Routes
    root to: "posts.index"

    get "/posts", to: "posts.index", as: :posts
    get "/posts/:id", to: "posts.show"
    post "/posts", to: "posts.create"
    get "/posts/-/anything", to: "posts.anything"
    get "/posts/-/nested", to: "posts.nested"
    get "/posts/-/redirect", to: "posts.redirect"
    get "/posts/-/prerendered", to: "posts.prerendered"
    get "/posts/-/plain", to: "posts.plain"
    get "/posts/-/viewless", to: "posts.viewless"
    get "/posts/-/boxed", to: "posts.boxed"
    get "/posts/-/translated", to: "posts.translated"
    get "/posts/-/form", to: "posts.form"
    get "/posts/-/feed", to: "posts.feed"
    get "/posts/-/opted-out", to: "posts.opted_out"
    get "/posts/-/conditional", to: "posts.conditional"
    get "/posts/-/escaping", to: "posts.escaping"
    get "/posts/-/kitted", to: "posts.kitted"

    slice :admin, at: "/admin" do
      get "/posts", to: "posts.index"
      get "/posts/bare", to: "posts.bare"
      get "/posts/shared", to: "posts.shared"
    end
  end
end
