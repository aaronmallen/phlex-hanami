# frozen_string_literal: true

module TestApp
  module Components
    class Middle < TestApp::View
      def view_template
        div { render TestApp::Components::Inner.new }
      end
    end
  end
end
