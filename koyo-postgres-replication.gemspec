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

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = url
  spec.metadata['changelog_uri'] = "#{url}/changelog.md"

  # spec.files = Dir.chdir(File.expand_path(__dir__)) do
  #  Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  # end

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) ==
       __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'pg', '~> 1.1'
  spec.add_dependency 'rails', '~> 7.0.0'
  spec.add_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'yard'

  spec.has_rdoc = 'yard'
end
