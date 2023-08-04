# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in koyo_repl.gemspec
gemspec

gem 'rails', '~> 7.0.4', '>= 7.0.4.3'
gem 'rake', '~> 13.0'
# gem "rspec", "~> 3.0"
gem 'pg', '~> 1.1'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'rspec-rails', '~> 6.0.0'
  gem 'rubocop'
  gem 'yard'
end
