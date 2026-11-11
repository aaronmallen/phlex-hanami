# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      class Create < TestApp::Action
        def handle(_request, response)
          response[:errors] = ["Title is required"]
        end
      end
    end
  end
end
