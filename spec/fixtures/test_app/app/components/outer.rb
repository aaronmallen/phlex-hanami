# frozen_string_literal: true

module TestApp
  module Components
    class Outer < Phlex::Hanami::Component
      def view_template
        div { render TestApp::Components::Middle.new }
      end
    end
  end
end
