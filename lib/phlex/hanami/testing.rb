# frozen_string_literal: true

require "phlex/hanami"
require "rack/mock_request"

module Phlex
  module Hanami
    # Test support for view and component specs, whatever the test framework.
    #
    # A Phlex view is an ordinary Ruby object, so most of it needs no help: build one and call it.
    # What it does need is a view context, because a view that reaches for `path`, `assets` or
    # `flash` reads them off the context Hanami builds per request. {ViewHelpers} gives you that
    # context without a request, and a fake request when the view wants one.
    #
    # `require "phlex/hanami/rspec"` includes the helpers into every RSpec example group tagged
    # `type: :view`. Under any other framework, require this file and include the module yourself:
    #
    #     # test/support/phlex.rb
    #     require "phlex/hanami/testing"
    #
    #     class Hanami::Minitest::Test
    #       include Phlex::Hanami::Testing::ViewHelpers
    #     end
    #
    # @api public
    # @since 0.2.0
    module Testing
      # Renders a view or component, and builds what a view needs to render.
      #
      # Nothing here is tied to a test framework. Include it into whichever class or example group
      # your view tests run in.
      #
      # @example
      #   class PostIndexTest < Hanami::Minitest::Test
      #     include Phlex::Hanami::Testing::ViewHelpers
      #
      #     test "lists the posts" do
      #       assert_includes render(MyApp::Views::Posts::Index.new(posts: [post])), "<h1>Posts</h1>"
      #     end
      #   end
      #
      # @api public
      # @since 0.2.0
      module ViewHelpers
        # Renders a view or component and returns the markup.
        #
        # Renders the instance you pass, so no layout is applied. Call the class instead
        # (`described_class.call(context: view_context, **input)`) to render a view inside its
        # layout, the way Hanami does.
        #
        # The context comes from the view's own slice, so routes, assets and translations are the
        # real ones. Pass `request:` for a view that reads the session, the flash or the CSRF
        # token, or `context:` to supply the whole context yourself.
        #
        # @example A component that takes a block
        #   render(Card.new(title: "Hello")) { "body" }
        #
        # @param view [Phlex::SGML] the view or component instance
        # @param context [Object, nil] a view context, built from the view's slice when omitted
        # @param request [Hanami::Action::Request, nil] a request for the context to carry
        #
        # @return [String] the rendered markup
        #
        # @api public
        # @since 0.2.0
        #: (
        #    ::Phlex::SGML,
        #    ?context: (::Hanami::View::Context | Context)?,
        #    ?request: ::Hanami::Action::Request?
        #  ) ?{ (?) -> untyped } -> String
        def render(view, context: nil, request: nil, &)
          context ||= view_context(slice: slice_for(view), request: request)

          view.call(context: { CONTEXT_KEY => context }, &)
        end

        # Builds a view context.
        #
        # Uses the same context class an action would: a `Hanami::View::Context` subclass when
        # hanami-view is bundled, otherwise a {Phlex::Hanami::Context} subclass. Either way the
        # slice's own routes, assets, inflector and i18n backend are injected.
        #
        # Falls back to a bare {Phlex::Hanami::Context} when there is no slice to build from. That
        # context answers `content_for` and raises a helpful error for anything needing a slice or
        # a request, which is what a view rendered outside an app should see.
        #
        # @param slice [Hanami::Slice, nil] the slice to build from, defaulting to the app
        # @param request [Hanami::Action::Request, nil] a request for the context to carry
        # @param options [Hash] passed on to the context's initializer
        #
        # @return [Object] the context
        #
        # @api public
        # @since 0.2.0
        #: (
        #    ?slice: singleton(::Hanami::Slice)?,
        #    ?request: ::Hanami::Action::Request?,
        #    **untyped
        #  ) -> (::Hanami::View::Context | Context)
        def view_context(slice: nil, request: nil, **)
          slice ||= ::Hanami.app if ::Hanami.app?
          context_class = slice ? Extensions::Slice.view_context_class(slice) : Context

          context_class.new(request: request, **)
        end

        # Builds a request for a view to read, without running an action.
        #
        # Sessions are always enabled on it, so `session`, `flash` and `csrf_token` answer rather
        # than raising `Hanami::Action::MissingSessionError`.
        #
        # @example
        #   render(described_class.new, request: view_request("/posts", flash: { alert: "Nope" }))
        #
        # @param path [String] the request path
        # @param csrf_token [String, nil] the token `csrf_token` returns
        # @param flash [Hash] the flash for this request
        # @param session [Hash] the session, keyed by String
        # @param options [Hash] passed on to `Rack::MockRequest.env_for`
        #
        # @return [Hanami::Action::Request]
        #
        # @api public
        # @since 0.2.0
        #: (
        #    ?String,
        #    ?csrf_token: String?,
        #    ?flash: Hash[Symbol | String, untyped],
        #    ?session: Hash[Symbol | String, untyped],
        #    **untyped
        #  ) -> ::Hanami::Action::Request
        def view_request(path = "/", csrf_token: nil, flash: {}, session: {}, **)
          env = ::Rack::MockRequest.env_for(path, **)
          env["rack.session"] = session.transform_keys(&:to_s)
          env["rack.session"][::Hanami::Action::Flash::KEY] = flash unless flash.empty?
          env["rack.session"][::Hanami::Action::CSRFProtection::CSRF_TOKEN.to_s] = csrf_token if csrf_token

          ::Hanami::Action::Request.new(
            env: env,
            params: ::Hanami::Action::Params.new(env: env),
            session_enabled: true,
          )
        end

        private

        # The slice a view belongs to. Nil for a plain Phlex class, which has no `slice` at all,
        # and for a Renderable one defined outside a slice namespace.
        #: (::Phlex::SGML) -> singleton(::Hanami::Slice)?
        def slice_for(view)
          view.class.slice if view.class.respond_to?(:slice)
        end
      end
    end
  end
end
