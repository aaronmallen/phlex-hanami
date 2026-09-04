# frozen_string_literal: true

require "hanami/view"
require "hanami/extensions/view/standard_helpers"

# Hanami's helpers return `SafeString`s meant to be interpolated into a template. Marking the class
# as a Phlex safe object lets Phlex emit them without escaping — both through `raw` and, more often,
# as the return value of a block.
Hanami::View::HTML::SafeString.include(Phlex::SGML::SafeObject)

module Phlex
  module Hanami
    # Hanami's standard helper library, for Phlex views that want it.
    #
    # Opt in per base class; it is not included in {View}, because it adds around twenty methods and
    # needs the hanami-view gem, and neither should depend on what happens to be in your Gemfile.
    #
    # @example
    #   module MyApp
    #     class View < Phlex::Hanami::View
    #       include Phlex::Hanami::Helpers
    #     end
    #   end
    #
    #   class Edit < MyApp::View
    #     def view_template
    #       raw form_for("post", path(:posts)) { |f| f.text_field(:title) + f.submit("Save") }
    #     end
    #   end
    #
    # Most of Hanami's helpers duplicate something Phlex already does better — Phlex escapes by
    # default and is itself a tag builder — so reach for `form_for`, `format_number` and the asset
    # helpers, and write everything else as ordinary Phlex.
    #
    # @api public
    # @since 0.2.0
    module Helpers
      # Hanami's helper library defines two methods Phlex already owns.
      #
      # Both of Hanami's return strings to interpolate; Phlex's write into the output buffer.
      # Letting Hanami's win breaks `raw` silently — the helper's output simply never appears — and
      # `raw` is the method you need in order to emit a helper's result at all.
      #
      # @api private
      # @since 0.2.0
      OVERRIDDEN_METHODS = {
        raw: Phlex::SGML.instance_method(:raw),
        tag: Phlex::HTML.instance_method(:tag),
      }.freeze

      # Phlex's implementations, mixed back in over Hanami's.
      #
      # @api private
      # @since 0.2.0
      PhlexMethods = ::Module.new do
        OVERRIDDEN_METHODS.each do |name, method|
          define_method(name) { |*args, **options, &block| method.bind_call(self, *args, **options, &block) }
        end
      end

      # @api private
      # @since 0.2.0
      def self.included(view_class)
        view_class.include(::Hanami::Extensions::View::StandardHelpers)
        view_class.include(PhlexMethods)
      end
    end
  end
end
