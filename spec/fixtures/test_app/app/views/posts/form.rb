# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      # Exercises Hanami's helper library. The include is conditional because the helpers hard-require
      # hanami-view, which the main suite deliberately does not bundle; `spec/integration` renders
      # this through a subprocess that does.
      class Form < TestApp::View
        include Phlex::Hanami::Helpers if Hanami.bundled?("hanami-view")

        def initialize(post:, errors: {})
          @post = post
          @errors = errors
        end

        def view_template
          h1 { "Edit post" }

          raw(form_for("post", "/posts/1", values: { post: @post }, method: :patch) do |f|
            f.label("Title", for: :title) + f.text_field(:title) + f.submit("Save")
          end)

          # Hanami's FormHelper has no error rendering of its own; that stays the app's job.
          ul(class: "errors") { @errors.fetch(:title, []).each { |message| li { message } } }

          p(id: "formatted") { format_number(1234.5678, precision: 2) }

          # Phlex's own `tag` must survive being mixed with Hanami's.
          tag(:custom_element, id: "phlex-tag") { "still Phlex" }
        end
      end
    end
  end
end
