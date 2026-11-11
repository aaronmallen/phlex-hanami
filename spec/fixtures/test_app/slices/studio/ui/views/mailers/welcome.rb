# frozen_string_literal: true

module Studio
  module Ui
    module Views
      module Mailers
        class Welcome < Phlex::Hanami::Mailer::View
          def view_template
            h1 { "Welcome to the studio" }
          end
        end
      end
    end
  end
end
