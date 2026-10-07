# frozen_string_literal: true

module Studio
  module Mailers
    class Welcome < Hanami::Mailer
      from "studio@example.com"
      to "user@example.com"
      subject "Welcome to the studio"
    end
  end
end
