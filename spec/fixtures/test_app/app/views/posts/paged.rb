# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      class Paged < TestApp::View
        include Phlex::Hanami::Props

        prop :page, Types::Params::Integer.default(1)

        def view_template
          p { "#{@page.class} #{@page}" }
        end
      end
    end
  end
end
