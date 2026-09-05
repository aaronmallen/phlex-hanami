# frozen_string_literal: true

module TestApp
  module Views
    module Mailers
      class Sessioned < Phlex::Hanami::Mailer::View
        layout nil

        def view_template
          p { session[:user_id].to_s }
        end
      end
    end
  end
end
