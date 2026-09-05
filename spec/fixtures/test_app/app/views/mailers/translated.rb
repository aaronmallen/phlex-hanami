# frozen_string_literal: true

module TestApp
  module Views
    module Mailers
      class Translated < Phlex::Hanami::Mailer::View
        layout nil

        def view_template
          h1 { t(".heading") }
        end
      end
    end
  end
end
