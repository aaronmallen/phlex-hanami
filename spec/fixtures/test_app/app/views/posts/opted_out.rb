# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      # Paired with an action that opts out; must never render.
      class OptedOut < TestApp::View
        def view_template
          h1 { "SHOULD NOT RENDER" }
        end
      end
    end
  end
end
