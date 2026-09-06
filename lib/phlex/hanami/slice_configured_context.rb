# frozen_string_literal: true

module Phlex
  module Hanami
    # Provides slice-specific dependencies to a {Context} subclass defined in a slice's namespace.
    #
    # Mirrors `Hanami::Extensions::View::SliceConfiguredContext`, so a context built without
    # hanami-view is injected with the same components Hanami would have injected with it.
    #
    # @api private
    # @since 0.2.0
    class SliceConfiguredContext < Module
      # The slice this module configures for.
      #
      # @return [Hanami::Slice]
      #
      # @api private
      # @since 0.2.0
      attr_reader :slice #: singleton(::Hanami::Slice)

      # @api private
      # @since 0.2.0
      #: (singleton(::Hanami::Slice)) -> void
      def initialize(slice)
        super()
        @slice = slice
      end

      # @api private
      # @since 0.2.0
      #: (singleton(Context)) -> void
      def extended(_context_class)
        define_new
      end

      # @api private
      # @since 0.2.0
      #: () -> String
      def inspect
        "#<#{self.class.name}[#{slice.name}]>"
      end

      private

      # Defines a `.new` that resolves the slice's components and passes them to `#initialize`.
      #: () -> void
      def define_new
        dependencies = method(:dependencies)

        define_method(:new) do |**kwargs|
          super(**dependencies.call.merge(kwargs))
        end
      end

      # The slice components a context is injected with, resolved fresh for each context so that
      # a container which does not memoize still hands out working objects.
      #: () -> Hash[Symbol, untyped]
      def dependencies
        { assets: resolve_assets, i18n: resolve_i18n, inflector: slice.inflector, routes: resolve_routes }
      end

      #: () -> ::Hanami::Assets?
      def resolve_assets
        slice["assets"] if slice.key?("assets")
      end

      #: () -> ::Hanami::Providers::I18n::Backend?
      def resolve_i18n
        slice["i18n"] if slice.key?("i18n")
      end

      #: () -> ::Hanami::Slice::RoutesHelper?
      def resolve_routes
        slice["routes"] if slice.key?("routes")
      end
    end
  end
end
