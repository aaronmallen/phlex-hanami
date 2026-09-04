# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      class Redirect < TestApp::Action
        def handle(_request, response)
          response.redirect_to("/posts")
        end
      end
    end
  end
end
