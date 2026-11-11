# frozen_string_literal: true

module Phlex
  module Hanami
    module Mailer
      # The base class for mail layouts.
      #
      # Name one `Views::Mailers::Layout` in a slice's namespace and every mail view in that slice
      # renders inside it. The web layout is never used for mail; set a different one with `layout`,
      # or opt out with `layout nil`.
      #
      # The layout is part of both message parts: the text part is converted from the HTML the
      # layout produced, so a footer written once appears in both.
      #
      # @example
      #   # app/views/mailers/layout.rb
      #   module MyApp
      #     module Views
      #       module Mailers
      #         class Layout < Phlex::Hanami::Mailer::Layout
      #           def view_template
      #             html do
      #               body do
      #                 yield
      #                 p { "Sent by MyApp" }
      #               end
      #             end
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
end
