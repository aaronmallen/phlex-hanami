# frozen_string_literal: true

module Phlex
  module Hanami
    # Makes a Phlex class renderable by Hanami.
    #
    # Include this into an existing `Phlex::SGML` subclass, or subclass {View}, which includes it
    # already. It gives the class the `call` contract Hanami's `Response#render` expects, a layout,
    # and everything in {Contextual}: per-slice configuration and the request's view context.
    #
    # A component is not called by Hanami and wants no layout, so it includes {Contextual} on its
    # own. {Component} does that already.
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
      KEYWORD_TYPES = %i[key keyreq].freeze #: Array[Symbol]

      # Distinguishes "no layout was configured" from "a layout of `nil` was configured", which is
      # how a view opts out.
      #
      # @api private
      # @since 0.2.0
      UNSET = ::Object.new.freeze #: Object

      # @api private
      # @since 0.2.0
      #: (singleton(::Phlex::SGML)) -> void
      def self.included(view_class)
        view_class.include(Contextual)
        view_class.extend(ClassMethods)
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
        #: (?context: (::Hanami::View::Context | Context)?, **untyped) -> String
        def call(context: nil, **input)
          phlex_context = { CONTEXT_KEY => context }
          body = new(**accepted_input(input)).call(context: phlex_context)

          layout_class = layout
          return body unless layout_class

          layout_class.new.call(context: phlex_context) { |layout| layout.raw(layout.safe(body)) }
        end

        # The layout configured on this class, or inherited from a superclass. {UNSET} when none has
        # been configured anywhere in the chain.
        #
        # @api private
        # @since 0.2.0
        #: () -> (singleton(::Phlex::SGML) | Object | nil)
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
        #: (?singleton(::Phlex::SGML)?) -> singleton(::Phlex::SGML)?
        def layout(layout_class = UNSET)
          unless UNSET.equal?(layout_class)
            @layout = layout_class
            return layout_class
          end

          configured = configured_layout
          UNSET.equal?(configured) ? default_layout : configured
        end

        private

        # Keeps only the keywords `initialize` declares.
        #
        # A view whose initializer takes `**` opts out and receives everything, request params
        # included.
        #: (Hash[Symbol, untyped]) -> Hash[Symbol, untyped]
        def accepted_input(input)
          parameters = instance_method(:initialize).parameters
          return input if parameters.any? { |type, _| type == :keyrest }

          input.slice(*parameters.filter_map { |type, name| name if KEYWORD_TYPES.include?(type) })
        end

        # The slice's conventional layout: `Views::Layout` in the slice's namespace, if it defines
        # one. Resolved on each call rather than memoized, so code reloading is not defeated.
        #: () -> singleton(::Phlex::SGML)?
        def default_layout
          return nil unless slice
          return nil unless slice.namespace.const_defined?(:Views, false)

          views = slice.namespace.const_get(:Views, false)
          views.const_get(:Layout, false) if views.const_defined?(:Layout, false)
        end
      end
    end
  end
end
