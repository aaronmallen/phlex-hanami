# frozen_string_literal: true

module Phlex
  module Hanami
    # The base class for everything below a view.
    #
    # A component is an ordinary Phlex class you render with `render`. It reads the same context a
    # view does — `path`, `assets`, `content_for`, `flash`, translations — because Phlex shares that
    # context with every component in the tree, however deep. What it does not have is the half of a
    # view that belongs to Hanami: no layout, and no `call(context:, **input)` entry point, because
    # Hanami never calls a component.
    #
    # Subclass this, or include {Contextual} into a base class you already have.
    #
    # @example
    #   # app/components/card.rb
    #   module MyApp
    #     module Components
    #       class Card < Phlex::Hanami::Component
    #         def initialize(post:) = @post = post
    #
    #         def view_template
    #           article do
    #             h2 { a(href: path(:post, id: @post.id)) { @post.title } }
    #             yield if block_given?
    #           end
    #         end
    #       end
    #     end
    #   end
    #
    # A component takes the context of whoever renders it, not its own slice's, so one written in
    # the app namespace works unchanged inside a slice's view.
    #
    # @api public
    # @since 0.2.0
    class Component < Phlex::HTML
      include Contextual
    end
  end
end
