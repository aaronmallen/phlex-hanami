# frozen_string_literal: true

module Blog
  module Views
    module Posts
      class Index < Phlex::Hanami::View
        def view_template
          a(href: path(:blog_posts)) { "Posts" }
          a(href: path(:root)) { "Home" }
        end
      end
    end
  end
end
