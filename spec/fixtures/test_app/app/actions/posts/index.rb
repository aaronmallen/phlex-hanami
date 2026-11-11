# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      class Index < TestApp::Action
        def handle(_request, response)
          response[:title] = "Posts"
        end
      end
    end
  end
end
