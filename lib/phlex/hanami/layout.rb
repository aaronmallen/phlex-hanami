# frozen_string_literal: true

module Phlex
  module Hanami
    # The base class for layouts.
    #
    # A layout is an ordinary Phlex class that yields the view's body. Name one `Views::Layout` in a
    # slice's namespace and every view in that slice renders inside it; set a different one with
    # `layout`, or opt out with `layout nil`.
    #
    # The view's body is rendered before the layout, so anything the view puts on the context — a
    # `content_for(:page_title, ...)`, say — is already there when the layout renders its `head`.
    #
    # @example
    #   # app/views/layout.rb
    #   module MyApp
    #     module Views
    #       class Layout < Phlex::Hanami::Layout
    #         def view_template
    #           doctype
    #           html do
    #             head { title { hanami_context.content_for(:page_title) || "MyApp" } }
    #             body { yield }
    #           end
    #         end
    #       end
    #     end
    #   end
    #
    # @api public
    # @since 0.2.0
    class Layout < Phlex::HTML
      include Renderable

      # A layout is never itself wrapped in a layout.
      layout nil
    end
  end
end
