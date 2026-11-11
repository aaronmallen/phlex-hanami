# frozen_string_literal: true

module Phlex
  module Hanami
    module Mailer
      # The base class for Phlex views rendered by a Hanami mailer.
      #
      # Subclass this for a mail view, or for an app-level base mail view. If you already have your
      # own `Phlex::HTML` base class, include {Renderable} into it instead — the two are equivalent.
      #
      # A mailer finds its view by name, the way an action does: `MyApp::Mailers::Welcome` renders
      # `MyApp::Views::Mailers::Welcome`.
      #
      # @example
      #   # app/views/mailers/welcome.rb
      #   module MyApp
      #     module Views
      #       module Mailers
      #         class Welcome < Phlex::Hanami::Mailer::View
      #           def initialize(user:) = @user = user
      #
      #           def view_template
      #             h1 { "Welcome, #{@user.name}" }
      #             p { a(href: url(:root)) { "Get started" } }
      #           end
      #         end
      #       end
      #     end
      #   end
      #
      # @api public
      # @since 0.2.0
      class View < Phlex::HTML
        include Renderable
      end
    end
  end
end
