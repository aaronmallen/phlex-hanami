# frozen_string_literal: true

module Admin
  module Mailers
    class Report < Hanami::Mailer
      from "admin@example.com"
      to "admin@example.com"
      subject "Report"
    end
  end
end
