# frozen_string_literal: true

module Phlex
  module Hanami
    module Mailer
      # Makes a Phlex class renderable by a Hanami mailer.
      #
      # Include this into an existing `Phlex::SGML` subclass, or subclass {View}, which includes it
      # already. It builds on {Phlex::Hanami::Renderable} and adds the three things mail needs: a
      # context with no request behind it, a second format for the plain text part, and a layout
      # convention of its own.
      #
      # @example
      #   module MyApp
      #     class MailerView < Phlex::HTML
      #       include Phlex::Hanami::Mailer::Renderable
      #     end
      #   end
      #
      # @api public
      # @since 0.2.0
      module Renderable
        # @api private
        # @since 0.2.0
        def self.included(view_class)
          view_class.include(::Phlex::Hanami::Renderable)

          # Order matters: a module included later sits higher in the lookup chain, so the mail
          # methods have to go in after `Renderable`, not alongside them in this module.
          view_class.include(MailMethods)
          view_class.extend(ClassMethods)
        end

        # @api public
        # @since 0.2.0
        module ClassMethods
          # Renders one part of a mail message.
          #
          # This is what `Hanami::Mailer#render_view` calls, once per part, with the format naming
          # the part it wants. Hanami's mailer has no view context to hand over — there is no
          # request to build one from — so a mail view builds the slice's own context itself.
          #
          # @param context [Object, nil] the Hanami view context, built from the slice when omitted
          # @param format [Symbol] `:html` or `:text`
          # @param input [Hash] the mailer's exposures
          #
          # @return [String] the rendered part
          #
          # @api public
          # @since 0.2.0
          def call(context: nil, format: :html, **input)
            html = super(context: context || mail_context, **input)
            return html unless format.to_s == "text"

            new(**accepted_input(input)).text_body(html)
          end

          private

          # A slice's conventional mail layout: `Views::Mailers::Layout`, if it defines one.
          #
          # The web layout is the wrong one for an email — it carries the stylesheets, scripts and
          # page chrome no mail client wants — so mail looks for its own, and renders without a
          # layout when the slice has none.
          def default_layout
            return nil unless slice
            return nil unless slice.namespace.const_defined?(:Views, false)

            views = slice.namespace.const_get(:Views, false)
            return nil unless views.const_defined?(:Mailers, false)

            mailers = views.const_get(:Mailers, false)
            mailers.const_get(:Layout, false) if mailers.const_defined?(:Layout, false)
          end

          # The slice's view context, built without a request.
          #
          # The same class an action would be given, so a view reads the same in both places. What
          # a request would have filled in — `request`, `session`, `flash`, `csrf_token` — is
          # missing, and the context says so when a view reaches for it.
          def mail_context
            return nil unless slice

            Extensions::Slice.view_context_class(slice).new
          end
        end

        # What a mail view does differently.
        #
        # Included after `Phlex::Hanami::Renderable` so that it wins: a module included later sits
        # higher in the lookup chain.
        #
        # @api private
        # @since 0.2.0
        module MailMethods
          # Raises. An email is read outside the app, so a link in one needs a full URL.
          #
          # @raise [RelativePathError]
          #
          # @api public
          # @since 0.2.0
          def path(*, **)
            raise RelativePathError, self.class
          end

          # The plain text part of the message.
          #
          # Called with the rendered HTML, layout and all, and converts it by default. Override it
          # to write the text part by hand; the view's own state is there to read.
          #
          # @example
          #   def text_body(_html)
          #     "Welcome, #{@user.name}. Get started: #{url(:root)}"
          #   end
          #
          # @param html [String] the rendered HTML part
          #
          # @return [String] the text part
          #
          # @api public
          # @since 0.2.0
          def text_body(html)
            Text.call(html)
          end
        end
      end
    end
  end
end
