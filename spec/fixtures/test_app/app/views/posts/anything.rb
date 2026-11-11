# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      # Opts out of input filtering with a keyrest initializer, so it receives request params too.
      class Anything < TestApp::View
        def initialize(**input)
          @input = input
        end

        def view_template
          pre { @input.map { |key, value| "#{key}=#{value}" }.sort.join(" ") }
        end
      end
    end
  end
end
