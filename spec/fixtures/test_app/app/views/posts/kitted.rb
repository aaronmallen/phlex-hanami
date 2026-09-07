# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      class Kitted < TestApp::View
        include TestApp::Components

        def view_template
          Card(title: "Kitted") { p { "body" } }
        end
      end
    end
  end
end
