# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "has_validated_attributes/version"

Gem::Specification.new do |s|
  s.name                  = "has_validated_attributes"
  s.version               = HasValidatedAttributes::VERSION
  s.required_ruby_version = ">= 3.0.0"
  s.authors               = ["Kyle Ginavan"]
  s.date                  = "2010-05-18"
  s.description           = "has_validated_attributes is a Ruby on Rails gem that lets you validate your fields."
  s.email                 = "kylejginavan@gmail.com"
  s.extra_rdoc_files      = ["README.rdoc"]
  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.homepage              = "https://github.com/kylejginavan/has_validated_attributes"
  s.require_paths         = ["lib"]
  s.rubygems_version      = "1.5.2"
  s.summary               = "Ruby on Rails gem for validate data prior to save"
  # s.rubyforge_project     = "has_validated_attributes"

  s.add_development_dependency "byebug",                     "~> 11.0"
  s.add_development_dependency "combustion",                 "~> 1.1"
  s.add_development_dependency "database_cleaner",           "~> 1.7"
  s.add_development_dependency "has_normalized_attributes",  "~> 0.0", ">= 0.0.8"
  s.add_development_dependency "pg",                         "~> 1.1"
  s.add_development_dependency "rails",                      "~> 6.1"
  s.add_development_dependency "rspec",                      "~> 3.8"
  s.add_development_dependency "rspec_junit_formatter",      "~> 0.4"
  s.add_development_dependency "rspec-rails",                ">= 4.0.0beta2", "< 5.0"
  s.add_development_dependency "shoulda-matchers",           "~> 4.1"
  s.add_development_dependency "simplecov",                  "~> 0.17"
  s.add_development_dependency "sprockets",                  "~> 3.0"

  # test
  s.add_development_dependency "testhq",                      "~> 2.0"
end
