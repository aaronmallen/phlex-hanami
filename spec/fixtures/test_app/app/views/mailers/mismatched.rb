# frozen_string_literal: true

module TestApp
  module Views
    module Mailers
      # A web view sitting where a mail view belongs. It renders markup for both parts of a message,
      # so the mailer refuses it.
      class Mismatched < TestApp::View
        def view_template
          p { "Not a mail view" }
        end
      end
    end
  end
end
