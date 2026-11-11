# frozen_string_literal: true

require_relative "testing"

# Wires {Phlex::Hanami::Testing::ViewHelpers} into RSpec. Require it from `spec/spec_helper.rb`, or
# from a file under `spec/support`, which the spec helper hanami-rspec generates already loads:
#
#     require "phlex/hanami/rspec"
#
# The helpers go into every example group tagged `type: :view`. Tag component specs the same way; a
# component is a view as far as this is concerned.
RSpec.configure do |config|
  config.include Phlex::Hanami::Testing::ViewHelpers, type: :view
end
