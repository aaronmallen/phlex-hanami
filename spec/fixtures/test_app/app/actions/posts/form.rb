# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      class Form < TestApp::Action
        def handle(_request, response)
          response[:post] = { title: "" }
          response[:errors] = { title: ["is required"] }
        end
      end
    end
  end
end
