# frozen_string_literal: true

source "https://gem.coop"

gemspec

group :development do
  gem "irb"
end

group :development, :test do
  gem "hanami-action", "~> 3.0"
  gem "hanami-router", "~> 3.0"
  gem "i18n", "~> 1.14"
  gem "rack", "~> 3.0"
  gem "rack-test", "~> 2.0"
  gem "rspec", "~> 3"
  gem "simplecov", "~> 1", require: false
end

group :lint do
  gem "rbs", "~> 4"
  gem "rubocop", "~> 1"
  gem "rubocop-ordered_methods", "~> 0.14"
  gem "rubocop-performance", "~> 1"
  gem "rubocop-rspec", "~> 3"
end
