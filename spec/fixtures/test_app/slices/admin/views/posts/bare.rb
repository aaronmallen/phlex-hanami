# frozen_string_literal: true

module Admin
  module Views
    module Posts
      class Bare < Admin::View
        layout nil

        def view_template = h2 { "No layout here" }
      end
    end
  end
end
