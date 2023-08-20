# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in koyo_repl.gemspec
gemspec

gem 'composite_primary_keys', '~> 14.0'
gem 'pg', '~> 1.1'
gem 'rails', '~> 7.0'
gem 'rake', '~> 13.0'

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop'
  gem 'yard'
end
