# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      class Nested < TestApp::View
        def view_template
          render TestApp::Components::Outer.new
        end
      end
    end
  end
end
