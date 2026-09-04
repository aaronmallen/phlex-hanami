# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      class Viewless < TestApp::Action
        def handle(_request, response)
          response.body = "no view for this action"
        end
      end
    end
  end
end
