# frozen_string_literal: true

require "hanami"
require "phlex"
require "zeitwerk"

module Phlex
  # An object oriented view layer for Hanami.
  #
  # Requiring this file installs the integration: Phlex classes register in slice containers as
  # classes rather than instances, and a view context is made available to every slice.
  #
  # @api public
  # @since 0.2.0
  module Hanami
    # The key the Hanami view context is stored under in Phlex's user context.
    #
    # Phlex shares its user context with every component in a render tree, so nesting a component
    # any number of levels deep keeps the context reachable.
    #
    # @api private
    # @since 0.2.0
    CONTEXT_KEY = :__hanami_context__
  end
end

# Hanami only requires its i18n helper as part of its hanami-view extensions, but the helper itself
# is written to work without hanami-view, so pull it in directly when the i18n gem is there.
if Hanami.bundled?("i18n")
  require "i18n"
  require "hanami/helpers/i18n_helper"
end

Zeitwerk::Loader.new.tap do |loader|
  lib_dir = File.join(File.dirname(__FILE__), "hanami")
  loader.tag = "phlex-hanami"
  loader.push_dir(lib_dir, namespace: Phlex::Hanami)
  loader.collapse(File.join(lib_dir, "errors"))
  # Test support is opt in, so nothing here should autoload it. `rspec.rb` also has no constant of
  # its own for Zeitwerk to hang an autoload on.
  loader.ignore(__FILE__, File.join(lib_dir, "rspec.rb"), File.join(lib_dir, "testing.rb"))
end.setup

# Installs the integration. Referencing the constant is what autoloads it, so this cannot move into
# the file itself — nothing else would ever refer to it.
Hanami::Slice::ClassMethods.prepend(Phlex::Hanami::Extensions::Slice)

# Mail is a second entry point, and an optional one. Zeitwerk keeps the mail classes unloaded until
# something names one, but prepending onto `Hanami::Mailer` needs the constant to exist.
Phlex::Hanami::Extensions::Mailer.install if Hanami.bundled?("hanami-mailer")
