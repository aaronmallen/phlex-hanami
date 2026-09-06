# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      # A JSON action that happens to share a name with a view. Documents what Hanami does with it.
      class Feed < TestApp::Action
        config.formats.accept :json

        def handle(_request, response)
          response[:title] = "Posts"
        end
      end
    end
  end
end
