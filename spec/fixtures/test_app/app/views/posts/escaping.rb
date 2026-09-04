# frozen_string_literal: true

module TestApp
  module Views
    module Posts
      # Everything here is fed a string a user could have supplied.
      class Escaping < TestApp::View
        DANGEROUS = %(<script>alert("xss")</script>)

        def view_template
          p(id: "plain") { DANGEROUS }
          p(id: "attribute", title: DANGEROUS) { "attr" }
          p(id: "interpolated") { t("interpolated", name: DANGEROUS) }
        end
      end
    end
  end
end
