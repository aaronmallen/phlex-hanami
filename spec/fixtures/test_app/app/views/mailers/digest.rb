# frozen_string_literal: true

module TestApp
  module Views
    module Mailers
      class Digest < Phlex::Hanami::Mailer::View
        layout nil

        def initialize(count:)
          @count = count
        end

        def text_body(_html)
          "#{@count} new posts, in text"
        end

        def view_template
          p { "#{@count} new posts" }
        end
      end
    end
  end
end
