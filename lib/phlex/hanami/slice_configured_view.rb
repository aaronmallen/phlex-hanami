# frozen_string_literal: true

module Phlex
  module Hanami
    # Provides slice-specific configuration to a {Renderable} view defined in a slice's namespace.
    #
    # `Hanami::SliceConfigurable` calls `configure_for_slice` once per slice as views are defined,
    # so a view in the app namespace is configured for the app and one in a slice namespace is
    # configured for that slice.
    #
    # @api private
    # @since 0.2.0
    class SliceConfiguredView < Module
      # The slice this module configures for.
      #
      # @return [Hanami::Slice]
      #
      # @api private
      # @since 0.2.0
      attr_reader :slice

      # @api private
      # @since 0.2.0
      def initialize(slice)
        super()
        @slice = slice
      end

      # @api private
      # @since 0.2.0
      def extended(_view_class)
        define_slice
      end

      # @api private
      # @since 0.2.0
      def inspect
        "#<#{self.class.name}[#{slice.name}]>"
      end

      private

      def define_slice
        slice = @slice

        define_method(:slice) { slice }
      end
    end
  end
end
