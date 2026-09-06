# frozen_string_literal: true

module Phlex
  module Hanami
    # The view context used when the hanami-view gem is not bundled.
    #
    # Hanami builds a context once per request and hands it to the view as `context:`. When
    # hanami-view is bundled that context is a `Hanami::View::Context` and this class is unused;
    # otherwise phlex-hanami defines a `Views::Context` subclass of this in every slice.
    #
    # The public surface mirrors `Hanami::View::Context` so that a view reads the same either way.
    #
    # @api public
    # @since 0.2.0
    class Context
      extend ::Hanami::SliceConfigurable

      # @api private
      # @since 0.2.0
      #: (singleton(::Hanami::Slice)) -> void
      def self.configure_for_slice(slice)
        extend SliceConfiguredContext.new(slice)
      end

      # The app's inflector.
      #
      # @return [Dry::Inflector]
      #
      # @api public
      # @since 0.2.0
      attr_reader :inflector #: Dry::Inflector

      # @see SliceConfiguredContext#define_new
      #
      # @api private
      # @since 0.2.0
      #: (
      #    ?inflector: Dry::Inflector?,
      #    ?routes: ::Hanami::Slice::RoutesHelper?,
      #    ?assets: ::Hanami::Assets?,
      #    ?request: ::Hanami::Action::Request?,
      #    ?i18n: ::Hanami::Providers::I18n::Backend?,
      #    **untyped
      #  ) -> void
      def initialize(inflector: nil, routes: nil, assets: nil, request: nil, i18n: nil, **)
        @inflector = inflector
        @routes = routes
        @assets = assets
        @request = request
        @i18n = i18n
        @content_for = {}
      end

      # The slice's assets.
      #
      # @return [Hanami::Assets]
      #
      # @raise [Hanami::ComponentLoadError] when hanami-assets is not bundled, or no assets exist
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Assets
      def assets
        raise ::Hanami::ComponentLoadError, "Assets not available. #{assets_hint}" unless @assets

        @assets
      end

      # Store a string of markup for later use, or read back what was stored.
      #
      # @param key [Symbol] the content key
      # @param value [String, nil] the content, when no block is given
      #
      # @return [String, nil]
      #
      # @api public
      # @since 0.2.0
      #: (Symbol, ?String?) ?{ () -> String } -> String?
      def content_for(key, value = nil)
        if block_given?
          @content_for[key] = yield
          nil
        elsif value
          @content_for[key] = value
          nil
        else
          @content_for[key]
        end
      end

      # The current request's CSRF token.
      #
      # @return [String]
      #
      # @raise [Hanami::ComponentLoadError] when there is no request
      #
      # @api public
      # @since 0.2.0
      #: () -> String?
      def csrf_token
        request.session[::Hanami::Action::CSRFProtection::CSRF_TOKEN]
      end

      # The flash hash for the current request.
      #
      # @raise [Hanami::ComponentLoadError] when there is no request
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Action::Flash
      def flash
        request.flash
      end

      # The slice's i18n backend.
      #
      # @raise [Hanami::ComponentLoadError] when the i18n gem is not bundled
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Providers::I18n::Backend
      def i18n
        raise ::Hanami::ComponentLoadError, "the i18n gem is required to access translations" unless @i18n

        @i18n
      end

      # @api private
      # @since 0.2.0
      #: (self) -> void
      def initialize_copy(source)
        super
        @content_for = source.instance_variable_get(:@content_for).dup
      end

      # The current request, when the view is rendered from an action.
      #
      # @return [Hanami::Action::Request]
      #
      # @raise [Hanami::ComponentLoadError] when the view is not rendered from a request
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Action::Request
      def request
        unless @request
          raise ::Hanami::ComponentLoadError, <<~MESSAGE
            Request not available. Only views rendered from Hanami::Action instances have a request.
          MESSAGE
        end

        @request
      end

      # Whether a request is available.
      #
      # @return [Boolean]
      #
      # @api public
      # @since 0.2.0
      #: () -> bool
      def request?
        !!@request
      end

      # The app's routes helper.
      #
      # @return [Hanami::Slice::RoutesHelper]
      #
      # @raise [Hanami::ComponentLoadError] when hanami-router is not bundled or routes are undefined
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Slice::RoutesHelper
      def routes
        raise ::Hanami::ComponentLoadError, "the hanami-router gem is required to access routes" unless @routes

        @routes
      end

      # The session for the current request.
      #
      # @raise [Hanami::ComponentLoadError] when there is no request
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Action::Request::Session
      def session
        request.session
      end

      private

      #: () -> String
      def assets_hint
        if ::Hanami.bundled?("hanami-assets")
          "Have you put files into your assets directory?"
        else
          "The hanami-assets gem is required to access assets."
        end
      end
    end
  end
end
