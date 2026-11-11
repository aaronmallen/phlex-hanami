# frozen_string_literal: true

module Admin
  module Views
    module Posts
      class Index < Admin::View
        def initialize(title:)
          @title = title
        end

        def view_template
          hanami_context.content_for(:page_title, "Set by the view")
          h2 { @title }
        end
      end
    end
  end
end
