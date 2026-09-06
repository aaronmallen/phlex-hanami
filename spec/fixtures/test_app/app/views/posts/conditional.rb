# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      # Renders for the HTML request and never for the JSON one.
      class Conditional < TestApp::View
        def view_template
          h1 { "Posts" }
        end
      end
    end
  end
end
