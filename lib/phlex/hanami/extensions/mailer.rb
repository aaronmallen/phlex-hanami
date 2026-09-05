# frozen_string_literal: true

module Phlex
  module Hanami
    module Extensions
      # Pairs a Hanami mailer with a Phlex view.
      #
      # Prepended onto `Hanami::Mailer`, so it sits in front of hanami-mailer's own view handling
      # and answers first. A mailer's view is any object taking `call(format:, **input)`, which a
      # {Phlex::Hanami::Mailer::View} already is, so pairing is the whole of the integration:
      # nothing here teaches hanami-mailer what Phlex is.
      #
      # @api private
      # @since 0.2.0
      module Mailer
        # Prepends this onto `Hanami::Mailer`.
        #
        # Called from `phlex/hanami.rb` when hanami-mailer is bundled. Zeitwerk keeps the mail
        # classes unloaded until something names one, but a prepend needs the constant, so the
        # check belongs at the call site.
        #
        # @api private
        # @since 0.2.0
        def self.install
          ::Hanami::Mailer.prepend(self)
          ::Hanami::Mailer.singleton_class.prepend(ClassMethods)
        end

        # @api private
        # @since 0.2.0
        module ClassMethods
          # @api private
          # @since 0.2.0
          def configure_for_slice(slice)
            super
            extend SliceConfigured.new(slice)
          end

          # The mailer's paired Phlex view, or nil when it has none.
          #
          # The key is derived the way hanami-mailer derives a template name: underscore the class
          # name and drop the slice's own segment, so `MyApp::Mailers::Welcome` looks up
          # `views.mailers.welcome`. Resolved through the container on every call rather than
          # memoized, so code reloading is not defeated.
          #
          # @return [Class, nil]
          #
          # @raise [MailerViewError] when the paired view is a Phlex class that cannot render mail
          #
          # @api private
          # @since 0.2.0
          def phlex_view
            mailer_slice = slice
            return nil unless mailer_slice && name

            key = "views.#{view_name(mailer_slice)}"
            return nil unless mailer_slice.key?(key)

            view = mailer_slice[key]
            return nil unless view.is_a?(::Class) && view < ::Phlex::SGML
            raise MailerViewError.new(self, view) unless view < ::Phlex::Hanami::Mailer::Renderable

            view
          end

          # The slice this mailer belongs to, or nil when it is defined outside a slice namespace.
          #
          # @return [Hanami::Slice, nil]
          #
          # @api private
          # @since 0.2.0
          def slice
            nil
          end

          private

          def view_name(mailer_slice)
            mailer_slice.inflector
              .underscore(name)
              .sub(%r{^#{mailer_slice.slice_name.path}/}, "")
              .tr("/", ".")
          end
        end

        # The view this mailer renders.
        #
        # A view passed to the constructor wins, then the paired Phlex view, then whatever
        # hanami-mailer would have used on its own — so an app can render some of its mail with
        # Phlex and the rest with templates.
        #
        # @return [Object, nil]
        #
        # @api private
        # @since 0.2.0
        def view
          @view || self.class.phlex_view || super
        end
      end
    end
  end
end
