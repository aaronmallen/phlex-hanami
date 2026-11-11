# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      class Anything < TestApp::Action
        def handle(_request, response)
          response[:exposed] = "exposure"
        end
      end
    end
  end
end
