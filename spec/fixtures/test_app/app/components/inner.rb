# frozen_string_literal: true

module TestApp
  module Components
    class Inner < TestApp::View
      def view_template
        span(id: "deep") { path(:posts) }
      end
    end
  end
end
