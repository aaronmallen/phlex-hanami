# frozen_string_literal: true

module TestApp
  module Actions
    module Posts
      # Auto-renders for HTML and opts out for JSON, off the same paired view. Sets no body either
      # way, so the format check is the only thing stopping the JSON render.
      class Conditional < TestApp::Action
        config.formats.accept :html, :json

        def handle(_request, _response); end

        private

        def auto_render?(response) = super && response.format != :json
      end
    end
  end
end
