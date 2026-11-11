# frozen_string_literal: true

module TestApp
  module Views
    # Reads everything a view can only get from a request. Paired with no action.
    class SessionPanel < TestApp::View
      def view_template
        p(id: "user") { session[:user] }
        p(id: "notice") { flash[:notice] }
        p(id: "token") { csrf_token }
        p(id: "path") { path(:posts) }
      end
    end
  end
end
