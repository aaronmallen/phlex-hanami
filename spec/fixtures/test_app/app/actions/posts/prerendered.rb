# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      class Prerendered < TestApp::Action
        def handle(_request, response)
          response.body = "set by the action"
        end
      end
    end
  end
end
