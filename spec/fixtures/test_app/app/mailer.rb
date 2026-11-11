# frozen_string_literal: true

require "hanami/mailer"

module TestApp
  class Mailer < Hanami::Mailer
    from "hello@example.com"
    to "reader@example.com"
  end
end
