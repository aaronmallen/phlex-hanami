# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      class Show < TestApp::View
        def initialize(id:)
          @id = id
        end

        def view_template
          h1 { "Post #{@id}" }
        end
      end
    end
  end
end
