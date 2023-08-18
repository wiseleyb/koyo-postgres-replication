# frozen_string_literal: true

require_relative 'lib/koyo'

burl = 'https://github.com/wiseleyb'
url = "#{burl}/koyo-postgres-replication"

Gem::Specification.new do |spec|
  spec.name        = 'koyo-postgres-replication'
  spec.version     = Koyo::Repl::VERSION
  spec.authors     = ['Ben Wiseley']
  spec.email       = ['wiseleyb@gmail.com']
  spec.homepage    = burl
  spec.summary     = 'Postgres Replication'
  spec.description = 'Simple Postgres replication helper'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

  # spec.metadata["allowed_push_host"] = ''
  spec.metadata['changelog_uri'] = "#{url}/changelog.md"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = burl

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) ==
       __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'bin'
  spec.require_paths = ['lib']

  spec.add_dependency 'pg', '~> 1.1'
  spec.add_dependency 'rack', '~> 2.0', '>= 2.0.0'
  spec.add_dependency 'rails', '~> 7.0'
  spec.add_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.1'
  spec.add_development_dependency 'yard', '~> 0.9'
end
