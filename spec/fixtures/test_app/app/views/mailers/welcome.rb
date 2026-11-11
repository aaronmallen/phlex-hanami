# frozen_string_literal: true

module TestApp
  module Views
    module Mailers
      class Welcome < Phlex::Hanami::Mailer::View
        def initialize(name:)
          @name = name
        end

        def view_template
          h1 { "Welcome, #{@name}" }
          ul do
            li { a(href: url(:posts)) { "All posts" } }
            li { "Tea & biscuits" }
          end
        end
      end
    end
  end
end
