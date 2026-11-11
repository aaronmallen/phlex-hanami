# frozen_string_literal: true

module Phlex
  module Hanami
    # Phlex views for hanami-mailer.
    #
    # A mailer renders the same view twice, once for each part of the message, so a mail view
    # answers to a format: {Mailer::View} renders markup for the HTML part and converts that markup
    # for the text part. Everything else a view can do it can do too, except the parts of the
    # context that only exist during a request.
    #
    # @example
    #   # app/mailers/welcome.rb
    #   module MyApp
    #     module Mailers
    #       class Welcome < Hanami::Mailer
    #         from "hello@example.com"
    #         to { |user| user.email }
    #         subject "Welcome"
    #
    #         expose :user
    #       end
    #     end
    #   end
    #
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
    module Mailer
    end
  end
end
