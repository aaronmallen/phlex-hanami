# frozen_string_literal: true

module Phlex
  module Hanami
    module Extensions
      # Installs phlex-hanami into every slice, including the app.
      #
      # Prepended onto `Hanami::Slice::ClassMethods` so that it runs for the app and each of its
      # slices as they are prepared. Two things happen:
      #
      # 1. Phlex classes are registered in the slice container as classes rather than instances.
      #    `Dry::System` would otherwise call `new` on them while resolving, which raises for any
      #    view with a real initializer, and a memoized Phlex instance can only render once.
      # 2. A `Views::Context` is defined for the slice when hanami-view is not bundled, filling the
      #    third-party slot `Hanami::Extensions::Action::SliceConfiguredAction#view_context_class`
      #    looks in.
      #
      # @api private
      # @since 0.2.0
      module Slice
        # Returns Phlex classes as classes, and everything else as the loader would.
        #
        # `component.loader.constant` is what the default autoloading loader already calls, so no
        # extra loading happens here and a constant that fails to load still raises
        # `Dry::System::ComponentNotLoadableError`.
        #
        # @api private
        # @since 0.2.0
        COMPONENT_INSTANCE = proc { |component, *args, **kwargs|
          constant = component.loader.constant(component)

          if constant.is_a?(Class) && constant < Phlex::SGML
            constant
          else
            component.loader.call(component, *args, **kwargs)
          end
        } #: ^(untyped, *untyped, **untyped) -> untyped

        # @api private
        # @since 0.2.0
        #: (?String?) -> untyped
        def prepare(provider_name = nil)
          result = super

          unless provider_name
            Slice.register_phlex_components(self)
            Slice.define_view_context(self)
          end

          result
        end

        class << self
          # Defines `Views::Context` for the slice when nothing else has.
          #
          # Does nothing when hanami-view is bundled, because Hanami defines its own richer context
          # there, and returns the existing one when the user has defined it themselves.
          #
          # @return [Class, nil] the slice's context class
          #
          # @api private
          # @since 0.2.0
          #: (singleton(::Hanami::Slice)) -> singleton(Context)?
          def define_view_context(slice)
            return if ::Hanami.bundled?("hanami-view")

            namespace = views_namespace(slice)
            return namespace.const_get(:Context, false) if namespace.const_defined?(:Context, false)

            # The class is anonymous at this point, so the slice cannot be inferred from its name
            # the way `Hanami::SliceConfigurable` would; configure it explicitly instead.
            namespace.const_set(:Context, ::Class.new(Context).tap { |klass| klass.configure_for_slice(slice) })
          end

          # Installs {COMPONENT_INSTANCE} as the default for the slice container's component dirs.
          #
          # `Dry::System::Config::ComponentDirs` re-applies its defaults every time the dirs are
          # read, and only where a dir has not configured the setting itself, so setting this after
          # the dirs have been added covers all of them and clobbers nothing.
          #
          # @api private
          # @since 0.2.0
          #: (singleton(::Hanami::Slice)) -> void
          def register_phlex_components(slice)
            component_dirs = slice.container.config.component_dirs
            return if component_dirs.configured?(:instance)

            component_dirs.instance = COMPONENT_INSTANCE
          end

          # The class an action's view context is built from, for anything rendering outside a
          # request that needs the same one.
          #
          # Reads the third-party slot `Hanami::Extensions::Action::SliceConfiguredAction` reads,
          # so a mail view and a request view are given the same class.
          #
          # @return [Class]
          #
          # @api private
          # @since 0.2.0
          #: (singleton(::Hanami::Slice)) -> (singleton(::Hanami::View::Context) | singleton(Context))
          def view_context_class(slice)
            return ::Hanami::Extensions::View::Context.context_class(slice) if ::Hanami.bundled?("hanami-view")

            define_view_context(slice)
          end

          private

          #: (singleton(::Hanami::Slice)) -> Module
          def views_namespace(slice)
            if slice.namespace.const_defined?(:Views, false)
              slice.namespace.const_get(:Views, false)
            else
              slice.namespace.const_set(:Views, ::Module.new)
            end
          end
        end
      end
    end
  end
end
