# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      class New < TestApp::View
        def initialize(errors: [])
          @errors = errors
        end

        def view_template
          h1 { "New post" }
          ul { @errors.each { |error| li { error } } }
        end
      end
    end
  end
end
