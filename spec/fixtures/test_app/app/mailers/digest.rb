# frozen_string_literal: true

module TestApp
  module Mailers
    class Digest < TestApp::Mailer
      subject "Digest"

      expose :count
    end
  end
end
