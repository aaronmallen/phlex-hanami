# frozen_string_literal: true

module TestApp
  module Components
    class Card < Phlex::Hanami::Component
      def initialize(title:) = @title = title

      def view_template
        article do
          h2 { a(href: path(:posts)) { @title } }
          yield if block_given?
        end
      end
    end
  end
end
