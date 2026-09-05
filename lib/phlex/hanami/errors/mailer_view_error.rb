# frozen_string_literal: true

module Phlex
  module Hanami
    # Raised when a mailer's paired Phlex view cannot render a mail message.
    #
    # A mailer asks its view for two parts, and an ordinary view answers both with markup — which
    # would ship an email whose plain text part is HTML. Better to say so than to send it.
    #
    # @api public
    # @since 0.2.0
    class MailerViewError < Error
      # @api private
      # @since 0.2.0
      def initialize(mailer_class, view_class)
        super(<<~MESSAGE)
          #{mailer_class} is paired with #{view_class}, which is not a mail view.

          A mail view renders both parts of the message. Subclass the mail base class:

            class #{view_class} < Phlex::Hanami::Mailer::View

          or include the module into the base class you already have:

            include Phlex::Hanami::Mailer::Renderable
        MESSAGE
      end
    end
  end
end
