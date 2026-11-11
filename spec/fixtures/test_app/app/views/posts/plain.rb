# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      class Plain < Phlex::HTML
        def view_template
          h1 { "plain" }
        end
      end
    end
  end
end
