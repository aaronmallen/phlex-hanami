# frozen_string_literal: true

module TestApp
  module Views
    module Mailers
      class Relative < Phlex::Hanami::Mailer::View
        layout nil

        def view_template
          a(href: path(:posts)) { "All posts" }
        end
      end
    end
  end
end
