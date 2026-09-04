# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      class Boxed < TestApp::View
        layout TestApp::Views::BoxLayout

        def view_template = h1 { "Boxed" }
      end
    end
  end
end
