# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      # Paired with a JSON action by name alone.
      class Feed < TestApp::View
        def initialize(title:)
          @title = title
        end

        def view_template
          h1 { @title }
        end
      end
    end
  end
end
