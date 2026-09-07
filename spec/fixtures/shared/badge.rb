# frozen_string_literal: true

# A component outside every slice namespace. `Hanami::SliceConfigurable` finds no slice for it, so
# `slice` is nil and a relative translation key has nothing to resolve against. Everything that
# reads the view context still works, because the context comes from whoever renders it.
module Shared
  class Badge < Phlex::Hanami::Component
    def view_template = span(id: "badge") { path(:posts) }
  end
end
