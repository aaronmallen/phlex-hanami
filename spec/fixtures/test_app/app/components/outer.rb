# frozen_string_literal: true

module TestApp
  module Components
    class Outer < TestApp::View
      def view_template
        div { render TestApp::Components::Middle.new }
      end
    end
  end
end
