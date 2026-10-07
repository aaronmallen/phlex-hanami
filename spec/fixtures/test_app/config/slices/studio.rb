# frozen_string_literal: true

module Studio
  # Keeps its views under `ui.views` rather than `views`, so its layouts and mail views have to be
  # found there too.
  class Slice < Hanami::Slice
    config.actions.view_name_inference_base = "ui.views"
  end
end
