# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      # `TestApp::Views::Posts::Translated` → container key `posts.translated`, so `t(".heading")`
      # would resolve `posts.translated.heading`.
      class Translated < TestApp::View
        def view_template
          h1 { t("greeting") }
          p(id: "relative") { t(".heading") }
          p(id: "missing") { t("nope.not.here") }
        end
      end
    end
  end
end
