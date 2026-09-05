# frozen_string_literal: true

module Phlex
  module Hanami
    # Raised when a mail view asks for a relative path.
    #
    # An email is read outside the app, so a relative path in one is a dead link. Mail views raise
    # rather than render one.
    #
    # @api public
    # @since 0.2.0
    class RelativePathError < Error
      # @api private
      # @since 0.2.0
      def initialize(view_class)
        super(<<~MESSAGE)
          #{view_class} asked for a relative path, and an email needs a full URL.

          Use `url` instead:

            a(href: url(:post, id: @post.id)) { @post.title }
        MESSAGE
      end
    end
  end
end
