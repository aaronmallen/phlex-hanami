# frozen_string_literal: true

module Studio
  module Ui
    module Views
      module Mailers
        class Layout < Phlex::Hanami::Mailer::Layout
          def view_template
            div(id: "studio-mail") { yield }
          end
        end
      end
    end
  end
end
