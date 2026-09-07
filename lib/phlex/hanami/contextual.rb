# frozen_string_literal: true

module Phlex
  module Hanami
    # Gives a Phlex class the Hanami view context and the slice it was defined in.
    #
    # This is the half of the integration a component needs: `path`, `assets`, `content_for`,
    # `flash`, translations and the rest, read off the context Hanami builds for the request.
    # {Renderable} includes it and adds the `call` contract Hanami's `Response#render` expects;
    # include this on its own for a class Hanami never calls directly.
    #
    # {Component} subclasses it already. Include this instead when you have your own component base
    # class.
    #
    # @example
    #   module MyApp
    #     class Component < Phlex::HTML
    #       include Phlex::Hanami::Contextual
    #     end
    #   end
    #
    # @api public
    # @since 0.2.0
    module Contextual
      # @api private
      # @since 0.2.0
      #: (singleton(::Phlex::SGML)) -> void
      def self.included(view_class)
        view_class.extend(::Hanami::SliceConfigurable)
        view_class.extend(ClassMethods)
        return unless defined?(::Hanami::Helpers::I18nHelper)

        # Order matters: a module included later sits higher in the lookup chain, so the overrides
        # have to go in after Hanami's helper, not alongside it in this module.
        view_class.include(::Hanami::Helpers::I18nHelper)
        view_class.include(I18nOverrides)
      end

      # Relative-key resolution for Hanami's i18n helper.
      #
      # A Phlex view has no template, so Hanami's implementation — which reads
      # `_context.current_template_name` — cannot work. Included after `Hanami::Helpers::I18nHelper`
      # so that it wins: a module included later sits higher in the lookup chain.
      #
      # @api private
      # @since 0.2.0
      module I18nOverrides
        private

        # Resolves a relative translation key (`t(".title")`) against the view's own container key, so
        # `MyApp::Views::Posts::Index` looks up `posts.index.title`.
        #
        # Hanami's own implementation uses `_context.current_template_name`, which is hanami-view's
        # template stack and has no meaning for a Phlex view.
        #: (String | Symbol) -> (String | Symbol)
        def _resolve_i18n_key(key)
          return key unless key.to_s.start_with?(".")

          base = i18n_key_base
          unless base
            raise ::I18n::ArgumentError,
                  "Cannot resolve the relative translation key #{key.inspect} for #{self.class}. " \
                    "Give the view a name inside a slice, or use an absolute key (without a leading dot)."
          end

          "#{base}#{key}"
        end

        # The view's container key, dotted: `MyApp::Views::Posts::Index` in the app slice becomes
        # `posts.index`. Nil for an anonymous view, or one outside any slice.
        #: () -> String?
        def i18n_key_base
          view_slice = self.class.slice
          name = self.class.name
          return nil unless view_slice && name

          view_slice.inflector
            .underscore(name)
            .sub(%r{^#{view_slice.slice_name.path}/}, "")
            .sub(%r{^views/}, "")
            .tr("/", ".")
        end
      end

      # @api public
      # @since 0.2.0
      module ClassMethods
        # @api private
        # @since 0.2.0
        #: (singleton(::Hanami::Slice)) -> void
        def configure_for_slice(slice)
          extend SliceConfigured.new(slice)
        end

        # The slice this class belongs to, or nil when it is defined outside a slice namespace.
        #
        # A class with no slice still renders: the context comes from whoever is rendering it, not
        # from the slice. What it loses is the slice-relative half — `t(".title")` has nothing to
        # resolve against and raises.
        #
        # @return [Hanami::Slice, nil]
        #
        # @api public
        # @since 0.2.0
        #: () -> singleton(::Hanami::Slice)?
        def slice
          nil
        end
      end

      # The URL for an asset.
      #
      # @example
      #   script(src: asset_url("app.js"))
      #
      # @param source [String] the asset's source path
      #
      # @return [String] the URL
      #
      # @api public
      # @since 0.2.0
      #: (String) -> String
      def asset_url(source)
        assets[source].url
      end

      # The slice's assets.
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Assets
      def assets
        hanami_context.assets
      end

      # Stores a string of markup for later use, or reads back what was stored.
      #
      # @api public
      # @since 0.2.0
      #: (Symbol, ?String?) ?{ () -> String } -> String?
      def content_for(...)
        hanami_context.content_for(...)
      end

      # The current request's CSRF token.
      #
      # @return [String]
      #
      # @api public
      # @since 0.2.0
      #: () -> String?
      def csrf_token
        hanami_context.csrf_token
      end

      # The flash hash for the current request.
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Action::Flash
      def flash
        hanami_context.flash
      end

      # The Hanami view context for this render.
      #
      # Read from Phlex's user context, which is shared with every component in the render tree, so
      # a component nested any number of levels deep sees the same context.
      #
      # @return [Object] a `Hanami::View::Context` when hanami-view is bundled, otherwise a {Context}
      #
      # @raise [MissingContextError] when the view was rendered without a context
      #
      # @api public
      # @since 0.2.0
      #: () -> (::Hanami::View::Context | Context)
      def hanami_context
        context[CONTEXT_KEY] || raise(MissingContextError, self.class)
      end

      # Whether a Hanami view context is available.
      #
      # @return [Boolean]
      #
      # @api public
      # @since 0.2.0
      #: () -> bool
      def hanami_context?
        !context[CONTEXT_KEY].nil?
      end

      # The slice's i18n backend.
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Providers::I18n::Backend
      def i18n
        hanami_context.i18n
      end

      # The path for a named route.
      #
      # @example
      #   a(href: path(:posts)) { "Posts" }
      #
      # @return [String]
      #
      # @api public
      # @since 0.2.0
      #: (*untyped, **untyped) -> String
      def path(...)
        routes.path(...)
      end

      # The current request.
      #
      # @return [Hanami::Action::Request]
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Action::Request
      def request
        hanami_context.request
      end

      # Whether the view is being rendered from within a request.
      #
      # @return [Boolean]
      #
      # @api public
      # @since 0.2.0
      #: () -> bool
      def request?
        hanami_context? && hanami_context.request?
      end

      # The app's routes helper.
      #
      # @return [Hanami::Slice::RoutesHelper]
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Slice::RoutesHelper
      def routes
        hanami_context.routes
      end

      # The session for the current request.
      #
      # @api public
      # @since 0.2.0
      #: () -> ::Hanami::Action::Request::Session
      def session
        hanami_context.session
      end

      # The slice this class belongs to.
      #
      # @return [Hanami::Slice, nil]
      #
      # @api public
      # @since 0.2.0
      #: () -> singleton(::Hanami::Slice)?
      def slice
        self.class.slice
      end

      # The full URL for a named route.
      #
      # Hanami's routes helper returns a `URI`; Phlex writes strings, and rejects anything else as
      # an attribute value, so this hands back the string.
      #
      # @example
      #   a(href: url(:posts)) { "Posts" }
      #
      # @return [String]
      #
      # @api public
      # @since 0.2.0
      #: (*untyped, **untyped) -> String
      def url(...)
        routes.url(...).to_s
      end

      private

      # Hanami's helper modules reach for the view context under this name.
      #: () -> (::Hanami::View::Context | Context)
      def _context
        hanami_context
      end
    end
  end
end
