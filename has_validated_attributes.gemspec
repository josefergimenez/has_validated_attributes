# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "has_validated_attributes/version"

Gem::Specification.new do |s|
  s.name                  = "has_validated_attributes"
  s.version               = HasValidatedAttributes::VERSION
  s.required_ruby_version = ">= 3.4.0", "< 4.0.0"
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
  s.summary               = "Ruby on Rails gem for validate data prior to save"

  # ActiveSupport 8.0 passes quirks_mode, which JSON 3 rejects.

  s.add_dependency "json", "< 3"

  s.add_dependency "activerecord",                                           "~> 8.0.0"
  s.add_development_dependency "rails",                              "~> 8.0.0"

  s.add_development_dependency "ostruct",                            "~> 0.6"
  s.add_development_dependency "pg",                                 "~> 1.1"
  s.add_development_dependency "sprockets",                          "~> 3.0"

  # hq
  s.add_development_dependency "has_normalized_attributes",          "~> 6.0.0"

  s.add_development_dependency "testhq",                             "~> 6.0.0"
end
