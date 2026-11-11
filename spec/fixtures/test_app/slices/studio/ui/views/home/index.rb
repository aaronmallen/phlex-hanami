# frozen_string_literal: true

module Studio
  module Ui
    module Views
      module Home
        class Index < Phlex::Hanami::View
          def view_template
            h1 { "Studio" }
          end
        end
      end
    end
  end
end
