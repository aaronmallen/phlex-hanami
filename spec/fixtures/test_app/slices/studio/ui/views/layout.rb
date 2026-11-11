# frozen_string_literal: true

module Studio
  module Ui
    module Views
      class Layout < Phlex::Hanami::Layout
        def view_template
          main(id: "studio") { yield }
        end
      end
    end
  end
end
