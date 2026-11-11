# frozen_string_literal: true

module Blog
  # The slice's own routes, so the slice registers a "routes" of its own that knows nothing of the
  # "/blog" it is mounted at.
  class Routes < Hanami::Routes
    get "/posts", to: "posts.index", as: :posts
  end
end
