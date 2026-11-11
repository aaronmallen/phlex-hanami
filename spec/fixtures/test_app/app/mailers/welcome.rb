# frozen_string_literal: true

module TestApp
  module Mailers
    class Welcome < TestApp::Mailer
      subject "Welcome"

      expose :name
    end
  end
end
