# frozen_string_literal: true

module Admin
  module Actions
    module Posts
      class Index < Admin::Action
        def handle(_request, response)
          response[:title] = "Admin posts"
        end
      end
    end
  end
end
