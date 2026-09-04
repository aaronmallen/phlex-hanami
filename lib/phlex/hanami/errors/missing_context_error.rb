# frozen_string_literal: true

module Phlex
  module Hanami
    # Raised when a view reaches for the Hanami view context but was rendered without one.
    #
    # @api public
    # @since 0.2.0
    class MissingContextError < Error
      # @api private
      # @since 0.2.0
      def initialize(view_class)
        super(<<~MESSAGE)
          #{view_class} was rendered without a Hanami view context.

          Views rendered from an action are given one automatically. When rendering a view yourself,
          pass one:

            #{view_class}.call(context: MyApp::Views::Context.new)
        MESSAGE
      end
    end
  end
end
