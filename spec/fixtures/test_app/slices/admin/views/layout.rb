# frozen_string_literal: true

module Admin
  module Views
    # Picked up by convention: `Views::Layout` in the slice's namespace.
    class Layout < Phlex::Hanami::Layout
      def view_template
        html do
          head { title { hanami_context.content_for(:page_title) || "Admin" } }
          body { yield }
        end
      end
    end
  end
end
