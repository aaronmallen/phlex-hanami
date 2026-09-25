# frozen_string_literal: true

module Phlex
  module Hanami
    # Raised when a prop's type rejects the value it was given.
    #
    # The type's own error, when there is one, is kept as the `cause`.
    #
    # @api public
    # @since 0.3.0
    class InvalidPropError < Error
      # @api private
      # @since 0.3.0
      #: (Module, Symbol, String) -> void
      def initialize(view_class, name, reason)
        super(<<~MESSAGE)
          #{view_class} was given an invalid #{name.inspect} prop.

            #{reason}
        MESSAGE
      end
    end
  end
end
