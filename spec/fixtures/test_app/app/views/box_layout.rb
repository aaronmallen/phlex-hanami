# frozen_string_literal: true

module TestApp
  module Views
    class BoxLayout < Phlex::Hanami::Layout
      def view_template
        div(class: "box") { yield }
      end
    end
  end
end
