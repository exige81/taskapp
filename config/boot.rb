ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
require "ostruct" # Added to support OpenStruct in Rails 8 with StimulusReflex
require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
