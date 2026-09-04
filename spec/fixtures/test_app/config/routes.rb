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
    get "/posts/-/escaping", to: "posts.escaping"

    slice :admin, at: "/admin" do
      get "/posts", to: "posts.index"
      get "/posts/bare", to: "posts.bare"
    end
  end
end
