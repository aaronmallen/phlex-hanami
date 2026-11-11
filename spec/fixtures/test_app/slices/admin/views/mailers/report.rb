# frozen_string_literal: true

module Admin
  module Views
    module Mailers
      # The slice has a `Views::Layout`, which mail never uses, and no `Views::Mailers::Layout`, so
      # this renders unwrapped.
      class Report < Phlex::Hanami::Mailer::View
        def view_template
          h2 { "Admin report" }
        end
      end
    end
  end
end
