# frozen_string_literal: true

module Admin
  module Views
    module Posts
      # Renders a component from the app namespace, to prove a component takes the context of
      # whoever renders it rather than its own slice's.
      class Shared < Admin::View
        layout nil

        def view_template
          render TestApp::Components::Card.new(title: "Shared")
        end
      end
    end
  end
end
