# frozen_string_literal: true

module TestApp
  module Views
    module Mailers
      class Layout < Phlex::Hanami::Mailer::Layout
        def view_template
          html do
            head { title { "TestApp" } }
            body do
              yield
              p { "Sent by TestApp" }
            end
          end
        end
      end
    end
  end
end
