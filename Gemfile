# coding: utf-8
# frozen_string_literal: true

source "https://rubygems.org"

source "https://vLEyAxzPMpJK8itRTFw6@gem.fury.io/onehq/" do
  gem "has_normalized_attributes", "= 6.1.0"
  gem "testhq", "= 6.1.0"
end

# Specify your gem's dependencies in send_grid.gemspec
gemspec

# Verify both supported Rails series during the upgrade.
def next?
  File.basename(__FILE__) == "Gemfile.next"
end

gem "next_rails"
gem "rails", next? ? "= 8.1.3.1" : "= 8.0.5.1"
