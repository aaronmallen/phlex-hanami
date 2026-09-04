# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      class Index < TestApp::View
        def initialize(title:)
          @title = title
        end

        def view_template
          h1 { @title }
          a(href: path(:posts)) { "All posts" }
        end
      end
    end
  end
end
