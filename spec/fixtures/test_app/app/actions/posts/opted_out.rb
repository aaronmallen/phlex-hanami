# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      # Opts out of auto-rendering through Hanami's own hook, even though a view is paired.
      class OptedOut < TestApp::Action
        def handle(_request, _response); end

        private

        def auto_render?(_response) = false
      end
    end
  end
end
