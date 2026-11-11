# frozen_string_literal: true

module Phlex
  module Hanami
    # The base class for Phlex views rendered by Hanami.
    #
    # Subclass this for an app-level base view. If you already have your own `Phlex::HTML` base
    # class, include {Renderable} into it instead — the two are equivalent.
    #
    # @example
    #   # app/view.rb
    #   module MyApp
    #     class View < Phlex::Hanami::View
    #     end
    #   end
    #
    #   # app/views/posts/index.rb
    #   module MyApp
    #     module Views
    #       module Posts
    #         class Index < MyApp::View
    #           def initialize(posts:) = @posts = posts
    #
    #           def view_template
    #             h1 { "Posts" }
    #             ul { @posts.each { |post| li { post.title } } }
    #           end
    #         end
    #       end
    #     end
    #   end
    #
    # @api public
    # @since 0.2.0
    class View < Phlex::HTML
      include Renderable
    end
  end
end
