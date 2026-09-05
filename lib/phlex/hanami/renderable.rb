# frozen_string_literal: true

module Phlex
  module Hanami
    # Makes a Phlex class renderable by Hanami.
    #
    # Include this into an existing `Phlex::SGML` subclass, or subclass {View}, which includes it
    # already. It gives the class the `call` contract Hanami's `Response#render` expects, per-slice
    # configuration, and access to the request's view context.
    #
    # @example
    #   module MyApp
    #     class View < Phlex::HTML
    #       include Phlex::Hanami::Renderable
    #     end
    #   end
    #
    # @api public
    # @since 0.2.0
    module Renderable
      # The `Method#parameters` types that name a keyword argument.
      #
      # @api private
      # @since 0.2.0
      KEYWORD_TYPES = %i[key keyreq].freeze

      # Distinguishes "no layout was configured" from "a layout of `nil` was configured", which is
      # how a view opts out.
      #
      # @api private
      # @since 0.2.0
      UNSET = ::Object.new.freeze

      # @api private
      # @since 0.2.0
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
        # Renders the view to a String.
        #
        # This is the entry point Hanami's `Hanami::Action::Response#render` calls. Hanami passes
        # the request's view context as `context:` alongside every response exposure and request
        # param; `input` is filtered down to the keywords this view's `initialize` accepts, so an
        # unexpected param is dropped rather than raising.
        #
        # Exposures take precedence over params, which is Hanami's own merge order.
        #
        # When the view has a layout, the view's body is rendered first and then handed to the
        # layout. That ordering is what makes `content_for` set in the view visible in the layout's
        # `head`; Hanami assigns the whole response body at once, so nothing is streamed either way.
        #
        # @param context [Object, nil] the Hanami view context
        # @param input [Hash] exposures and params
        #
        # @return [String] the rendered markup
        #
        # @api public
        # @since 0.2.0
        def call(context: nil, **input)
          phlex_context = { CONTEXT_KEY => context }
          body = new(**accepted_input(input)).call(context: phlex_context)

          layout_class = layout
          return body unless layout_class

          layout_class.new.call(context: phlex_context) { |layout| layout.raw(layout.safe(body)) }
        end

        # @api private
        # @since 0.2.0
        def configure_for_slice(slice)
          extend SliceConfigured.new(slice)
        end

        # The layout configured on this class, or inherited from a superclass. {UNSET} when none has
        # been configured anywhere in the chain.
        #
        # @api private
        # @since 0.2.0
        def configured_layout
          return @layout if defined?(@layout)
          return superclass.configured_layout if superclass.respond_to?(:configured_layout)

          UNSET
        end

        # Reads or sets the layout this view renders inside.
        #
        # Called with no argument it reads: an explicit setting on this class, otherwise the
        # nearest superclass's, otherwise the slice's conventional `Views::Layout`.
        #
        # Layouts only apply at this entry point, so a component rendered with `render` is never
        # wrapped — only the view Hanami calls is.
        #
        # @example Set a layout for a whole slice, from its base view
        #   module MyApp
        #     class View < Phlex::Hanami::View
        #       layout MyApp::Views::AdminLayout
        #     end
        #   end
        #
        # @example Opt out, for a turbo frame or a partial response
        #   class Frame < MyApp::View
        #     layout nil
        #   end
        #
        # @param layout_class [Class, nil] the layout to render inside, or nil for none
        #
        # @return [Class, nil] the layout
        #
        # @api public
        # @since 0.2.0
        def layout(layout_class = UNSET)
          unless UNSET.equal?(layout_class)
            @layout = layout_class
            return layout_class
          end

          configured = configured_layout
          UNSET.equal?(configured) ? default_layout : configured
        end

        # The slice this view belongs to, or nil when it is defined outside a slice namespace.
        #
        # @return [Hanami::Slice, nil]
        #
        # @api public
        # @since 0.2.0
        def slice
          nil
        end

        private

        # Keeps only the keywords `initialize` declares.
        #
        # A view whose initializer takes `**` opts out and receives everything, request params
        # included.
        def accepted_input(input)
          parameters = instance_method(:initialize).parameters
          return input if parameters.any? { |type, _| type == :keyrest }

          input.slice(*parameters.filter_map { |type, name| name if KEYWORD_TYPES.include?(type) })
        end

        # The slice's conventional layout: `Views::Layout` in the slice's namespace, if it defines
        # one. Resolved on each call rather than memoized, so code reloading is not defeated.
        def default_layout
          return nil unless slice
          return nil unless slice.namespace.const_defined?(:Views, false)

          views = slice.namespace.const_get(:Views, false)
          views.const_get(:Layout, false) if views.const_defined?(:Layout, false)
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
      def asset_url(source)
        assets[source].url
      end

      # The slice's assets.
      #
      # @api public
      # @since 0.2.0
      def assets
        hanami_context.assets
      end

      # Stores a string of markup for later use, or reads back what was stored.
      #
      # @api public
      # @since 0.2.0
      def content_for(...)
        hanami_context.content_for(...)
      end

      # The current request's CSRF token.
      #
      # @return [String]
      #
      # @api public
      # @since 0.2.0
      def csrf_token
        hanami_context.csrf_token
      end

      # The flash hash for the current request.
      #
      # @api public
      # @since 0.2.0
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
      def hanami_context
        context[CONTEXT_KEY] || raise(MissingContextError, self.class)
      end

      # Whether a Hanami view context is available.
      #
      # @return [Boolean]
      #
      # @api public
      # @since 0.2.0
      def hanami_context?
        !context[CONTEXT_KEY].nil?
      end

      # The slice's i18n backend.
      #
      # @api public
      # @since 0.2.0
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
      def path(...)
        routes.path(...)
      end

      # The current request.
      #
      # @return [Hanami::Action::Request]
      #
      # @api public
      # @since 0.2.0
      def request
        hanami_context.request
      end

      # Whether the view is being rendered from within a request.
      #
      # @return [Boolean]
      #
      # @api public
      # @since 0.2.0
      def request?
        hanami_context? && hanami_context.request?
      end

      # The app's routes helper.
      #
      # @return [Hanami::Slice::RoutesHelper]
      #
      # @api public
      # @since 0.2.0
      def routes
        hanami_context.routes
      end

      # The session for the current request.
      #
      # @api public
      # @since 0.2.0
      def session
        hanami_context.session
      end

      # The slice this view belongs to.
      #
      # @return [Hanami::Slice, nil]
      #
      # @api public
      # @since 0.2.0
      def slice
        self.class.slice
      end

      # The full URL for a named route.
      #
      # @return [String]
      #
      # @api public
      # @since 0.2.0
      def url(...)
        routes.url(...)
      end

      private

      # Hanami's helper modules reach for the view context under this name.
      def _context
        hanami_context
      end
    end
  end
end
